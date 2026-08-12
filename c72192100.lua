--デスルークデーモン
-- 效果：
-- 这张卡的控制者在自己的每1个准备阶段支付500基本分。当这张卡成为对方所控制的卡的效果对象时，在效果处理时掷1次骰子，若掷出3，则使此效果无效并将其破坏。当自己场上的「灭绝国王恶魔」被破坏送去墓地时，可以从手卡将这张卡送去墓地，将此「灭绝国王恶魔」特殊召唤上场。
function c72192100.initial_effect(c)
	-- 这张卡的控制者在自己的每1个准备阶段支付500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c72192100.mtcon)
	e1:SetOperation(c72192100.mtop)
	c:RegisterEffect(e1)
	-- 当这张卡成为对方所控制的卡的效果对象时，在效果处理时掷1次骰子，若掷出3，则使此效果无效并将其破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DICE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c72192100.disop)
	c:RegisterEffect(e2)
	-- 当自己场上的「灭绝国王恶魔」被破坏送去墓地时，可以从手卡将这张卡送去墓地，将此「灭绝国王恶魔」特殊召唤上场。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetDescription(aux.Stringid(72192100,0))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCost(c72192100.spcost)
	e3:SetTarget(c72192100.sptg)
	e3:SetOperation(c72192100.spop)
	c:RegisterEffect(e3)
end
-- 准备阶段维持效果的条件函数：当前回合玩家是控制者
function c72192100.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为该卡的控制者
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段维持效果的处理：支付500基本分，或者在有「万魔殿-恶魔的巢窟-」存在时选择不支付，若无法支付则破坏该卡
function c72192100.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否能支付500基本分，或者是否受到「万魔殿-恶魔的巢窟-」的效果影响
	if Duel.CheckLPCost(tp,500) or Duel.IsPlayerAffectedByEffect(tp,94585852) then
		-- 检查玩家是否不受「万魔殿-恶魔的巢窟-」的效果影响
		if not Duel.IsPlayerAffectedByEffect(tp,94585852)
			-- 或者玩家选择不适用「万魔殿-恶魔的巢窟-」免除支付基本分的效果
			or not Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(94585852,1)) then  --"是否使用「万魔殿-恶魔的巢窟-」的效果不支付基本分？"
			-- 玩家支付500基本分
			Duel.PayLPCost(tp,500)
		end
	else
		-- 作为维持基本分的代替，将这张卡破坏
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
-- 掷骰子无效并破坏效果的处理：当成为对方卡的效果对象时，在效果处理时掷1次骰子，若为3则无效并破坏该卡
function c72192100.disop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前处理连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 如果对象不存在、对象不包含这张卡、或者该连锁效果无法被无效，则不进行处理
	if not tg or not tg:IsContains(e:GetHandler()) or not Duel.IsChainDisablable(ev) then return false end
	local rc=re:GetHandler()
	-- 玩家掷1次骰子
	local dc=Duel.TossDice(tp,1)
	if dc~=3 then return end
	-- 如果成功使该连锁的效果无效，且该卡在场上与该效果相关联
	if Duel.NegateEffect(ev,true) and rc:IsRelateToEffect(re) then
		-- 将该卡破坏
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
-- 特殊召唤效果的发动代价：将手卡的这张卡送去墓地
function c72192100.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为发动代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：检查是否是原本由自己控制、在场上被破坏送去墓地的「灭绝国王恶魔」，且能成为效果对象并能特殊召唤
function c72192100.filter(c,e,tp)
	return c:IsCode(35975813) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备：检查怪兽区域是否有空位，并选择被破坏的「灭绝国王恶魔」作为效果对象
function c72192100.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c72192100.filter(chkc,e,tp) end
	-- 检查玩家的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:IsExists(c72192100.filter,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=eg:FilterSelect(tp,c72192100.filter,1,1,nil,e,tp)
	-- 将选中的卡设为效果处理的对象
	Duel.SetTargetCard(g)
	-- 设置连锁的操作信息，表示该效果包含特殊召唤选中的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的实际处理：若怪兽区域有空位，则将作为对象的「灭绝国王恶魔」特殊召唤
function c72192100.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家的主要怪兽区域是否已无空位，若无则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取效果处理时的第一个对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到控制者的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
