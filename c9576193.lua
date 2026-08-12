--モンスター・スロット
-- 效果：
-- 选择自己场上表侧表示存在的1只怪兽，选择和选择的怪兽相同等级的自己墓地存在的1只怪兽从游戏中除外。那之后，从自己卡组抽1张卡。这个效果抽到的卡给双方确认，和选择的怪兽相同等级的怪兽的场合，那只怪兽特殊召唤。
function c9576193.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只怪兽，选择和选择的怪兽相同等级的自己墓地存在的1只怪兽从游戏中除外。那之后，从自己卡组抽1张卡。这个效果抽到的卡给双方确认，和选择的怪兽相同等级的怪兽的场合，那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c9576193.target)
	e1:SetOperation(c9576193.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示存在、且自己墓地存在相同等级可除外怪兽的怪兽
function c9576193.filter1(c,tp)
	local lv=c:GetLevel()
	-- 判定怪兽等级大于0、表侧表示，且墓地存在相同等级且可以除外的怪兽
	return lv>0 and c:IsFaceup() and Duel.IsExistingTarget(c9576193.filter2,tp,LOCATION_GRAVE,0,1,nil,lv)
end
-- 过滤墓地中与选择怪兽等级相同且可以除外的怪兽
function c9576193.filter2(c,lv)
	return c:IsLevel(lv) and c:IsAbleToRemove()
end
-- 效果发动时的对象选择与操作信息注册
function c9576193.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判定玩家是否能抽卡，以及场上是否存在满足条件的怪兽作为对象
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingTarget(c9576193.filter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上表侧表示存在的1只怪兽作为对象
	local g1=Duel.SelectTarget(tp,c9576193.filter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地存在的1只与选择怪兽相同等级的怪兽作为对象
	local g2=Duel.SelectTarget(tp,c9576193.filter2,tp,LOCATION_GRAVE,0,1,1,nil,g1:GetFirst():GetLevel())
	e:SetLabelObject(g1:GetFirst())
	-- 设置效果处理信息为除外墓地的目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g2,1,tp,LOCATION_GRAVE)
	-- 设置效果处理信息为玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理的执行函数
function c9576193.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc1=e:GetLabelObject()
	-- 获取当前连锁中被选择为对象的所有卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc2=g:GetFirst()
	if tc2==tc1 then tc2=g:GetNext() end
	if tc1:IsFacedown() or not tc1:IsRelateToEffect(e) then return end
	-- 判定墓地的目标怪兽是否仍符合条件并将其除外，若除外失败则结束处理
	if not tc2:IsRelateToEffect(e) or not tc2:IsLevel(tc1:GetLevel()) or Duel.Remove(tc2,POS_FACEUP,REASON_EFFECT)==0 then return end
	-- 中断当前效果，使后续的抽卡处理不与除外同时处理
	Duel.BreakEffect()
	-- 玩家从卡组抽1张卡，若抽卡失败则结束处理
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	-- 获取刚刚抽到的那张卡
	local dr=Duel.GetOperatedGroup():GetFirst()
	-- 将抽到的卡给对方玩家确认
	Duel.ConfirmCards(1-tp,dr)
	-- 中断当前效果，使后续的特殊召唤处理不与抽卡同时处理
	Duel.BreakEffect()
	if dr:IsLevel(tc1:GetLevel()) then
		-- 尝试将抽到的怪兽特殊召唤，若特殊召唤失败则执行后续处理
		if Duel.SpecialSummon(dr,0,tp,tp,false,false,POS_FACEUP)==0 then
			-- 将抽到的卡加入手卡并洗牌
			Duel.ShuffleHand(tp)
		end
	-- 若抽到的卡不是相同等级的怪兽，则将其加入手卡并洗牌
	else Duel.ShuffleHand(tp) end
end
