--ポンコツの意地
-- 效果：
-- 选择在自己墓地存在的3只名字带有「废铁」的怪兽发动。对方选择那些中的1只。那只怪兽在自己或对方场上特殊召唤，其余的卡从游戏中除外。
function c33970665.initial_effect(c)
	-- 选择在自己墓地存在的3只名字带有「废铁」的怪兽发动。对方选择那些中的1只。那只怪兽在自己或对方场上特殊召唤，其余的卡从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c33970665.target)
	e1:SetOperation(c33970665.activate)
	c:RegisterEffect(e1)
end
-- 判断卡是否为名字带有「废铁」的怪兽，且其能够被特殊召唤到自己或对方场上（表侧表示）。
function c33970665.filter(c,e,tp)
	return c:IsSetCard(0x24) and (c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp))
end
-- 取对象时验证对象是自己墓地的「废铁」怪兽且满足特殊召唤条件；发动时检查双方主要怪兽区有空位且自己墓地存在至少3只满足条件的「废铁」怪兽。
function c33970665.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c33970665.filter(chkc,e,tp) end
	-- 仅在发动判定（chk==0）时，确认我方或对方的主要怪兽区至少一侧有空位，否则不能发动。
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0)
		-- 同时确认自己墓地存在至少3只满足筛选条件且能成为对象的「废铁」怪兽，否则不能发动。
		and Duel.IsExistingTarget(c33970665.filter,tp,LOCATION_GRAVE,0,3,nil,e,tp) end
	-- 向发动者显示提示信息，要求其选择3只名字带有「废铁」的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(33970665,2))  --"请选择3只名字带有「废铁」的怪兽"
	-- 让发动者从自己墓地选择3只满足条件的「废铁」怪兽作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c33970665.filter,tp,LOCATION_GRAVE,0,3,3,nil,e,tp)
	-- 设置连锁操作信息：此效果含有特殊召唤，对象为选择的3只怪兽，预定特殊召唤数量为1（其余除外）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理阶段：取出仍关联的墓地「废铁」怪兽；若无对象或双方场上均无空位则终止；由对方选择其中1只，再根据可特殊召唤到的位置由我方决定召唤到哪一方，最后特殊召唤该怪兽并把其余对象除外。
function c33970665.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记过的对象（3只墓地怪兽），并过滤掉已经与该效果失去关联的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 计算我方主要怪兽区域的空位数，用于判断能否特殊召唤到我方场上。
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 计算对方主要怪兽区域的空位数，用于判断能否特殊召唤到对方场上。
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if g:GetCount()==0 or (ft1==0 and ft2==0) then return end
	-- 向对方玩家显示提示信息，请对方选择1只要特殊召唤的「废铁」怪兽。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tc=g:Select(1-tp,1,1,nil):GetFirst()
	local s1=ft1>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local s2=ft2>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
	local op=0
	-- 如果该怪兽既能特殊召唤到我方也能特殊召唤到对方场上，则让我方玩家选择召唤到哪一方（选项：在自己场上/在对方场上）。
	if s1 and s2 then op=Duel.SelectOption(tp,aux.Stringid(33970665,0),aux.Stringid(33970665,1))  --"在自己场上特殊召唤/在对方场上特殊召唤"
	-- 如果只能特殊召唤到我方场上，则只提供选项“在自己场上特殊召唤”，op记为0。
	elseif s1 then op=Duel.SelectOption(tp,aux.Stringid(33970665,0))  --"在自己场上特殊召唤"
	-- 如果只能特殊召唤到对方场上，则选择“在对方场上特殊召唤”后op再加1，使其对应后续的对方场分支。
	elseif s2 then op=Duel.SelectOption(tp,aux.Stringid(33970665,1))+1  --"在对方场上特殊召唤"
	else op=2 end
	-- op为0时，把那1只被对方选中的怪兽以表侧表示特殊召唤到我方场上。
	if op==0 then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	-- op为1时，把那1只怪兽以表侧表示特殊召唤到对方场上。
	elseif op==1 then Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP) end
	g:RemoveCard(tc)
	-- 将对象中未被特殊召唤的其余「废铁」怪兽全部从墓地除外。
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
