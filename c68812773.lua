--オボミ
-- 效果：
-- ①：这张卡召唤·反转时，以自己墓地1只「轨道 7」为对象才能发动。那只怪兽表侧攻击表示或者里侧守备表示特殊召唤。
-- ②：1回合1次，把自己场上的机械族怪兽任意数量解放才能发动。把解放数量的「光子」怪兽或者「银河」怪兽从手卡特殊召唤。
function c68812773.initial_effect(c)
	-- ①：这张卡召唤·反转时，以自己墓地1只「轨道 7」为对象才能发动。那只怪兽表侧攻击表示或者里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c68812773.sptg)
	e1:SetOperation(c68812773.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把自己场上的机械族怪兽任意数量解放才能发动。把解放数量的「光子」怪兽或者「银河」怪兽从手卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(68812773,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c68812773.spcost)
	e3:SetTarget(c68812773.sptg2)
	e3:SetOperation(c68812773.spop2)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己墓地中可以表侧攻击表示或里侧守备表示特殊召唤的「轨道 7」
function c68812773.filter(c,e,tp)
	return c:IsCode(71071546) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end
-- 效果①的靶向/发动准备阶段：检查怪兽区域空位，并选择自己墓地1只「轨道 7」作为效果对象
function c68812773.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c68812773.filter(chkc,e,tp) end
	-- 在发动准备阶段，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的「轨道 7」作为可选对象
		and Duel.IsExistingTarget(c68812773.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地1只满足条件的「轨道 7」作为效果对象
	local g=Duel.SelectTarget(tp,c68812773.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息：包含特殊召唤分类，操作对象为选择的怪兽，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的处理阶段：将作为对象的怪兽表侧攻击表示或者里侧守备表示特殊召唤
function c68812773.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧攻击表示或里侧守备表示特殊召唤，若特殊召唤成功且为里侧表示则进行后续处理
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)~=0 and tc:IsFacedown() then
			-- 让对方玩家确认里侧守备表示特殊召唤的怪兽
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
-- 过滤条件：手卡中可以特殊召唤的「光子」怪兽或「银河」怪兽
function c68812773.spfilter(c,e,tp)
	return c:IsSetCard(0x7b,0x55) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤条件：自己场上可解放的机械族怪兽（需考虑解放后是否能腾出怪兽区域空格）
function c68812773.cfilter(c,ft,tp)
	return c:IsRace(RACE_MACHINE)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
-- 效果②的发动代价阶段：解放自己场上任意数量的机械族怪兽，并记录解放的数量
function c68812773.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 在发动准备阶段，检查自己场上是否存在至少1只可解放的机械族怪兽
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c68812773.cfilter,1,nil,ft,tp) end
	-- 计算手卡中满足特殊召唤条件的「光子」或「银河」怪兽的最大数量
	local ct=Duel.GetMatchingGroupCount(c68812773.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 让玩家选择1张到最大数量张自己场上的机械族怪兽进行解放
	local rg=Duel.SelectReleaseGroup(tp,c68812773.cfilter,1,ct,nil,ft,tp)
	-- 解放选择的怪兽作为发动代价，并获取实际解放的数量
	ct=Duel.Release(rg,REASON_COST)
	e:SetLabel(ct)
end
-- 效果②的靶向/发动准备阶段：检查手卡中是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息
function c68812773.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查手卡中是否存在至少1只满足特殊召唤条件的「光子」或「银河」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c68812773.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	local ct=e:GetLabel()
	-- 设置当前连锁的操作信息：包含特殊召唤分类，数量为解放的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,0,0)
end
-- 效果②的处理阶段：从手卡选择与解放数量相同的「光子」怪兽或者「银河」怪兽表侧表示特殊召唤
function c68812773.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local ct=e:GetLabel()
	if ft<ct then ct=ft end
	-- 向玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择与解放数量相同（且不超过可用空格数）的「光子」或「银河」怪兽
	local dg=Duel.SelectMatchingCard(tp,c68812773.spfilter,tp,LOCATION_HAND,0,ct,ct,nil,e,tp)
	if dg:GetCount()>0 then
		-- 将选择的怪兽表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(dg,0,tp,tp,false,false,POS_FACEUP)
	end
end
