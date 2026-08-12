--デスピアン・プロスケニオン
-- 效果：
-- 「死狱乡」怪兽＋光属性怪兽＋暗属性怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，以对方墓地1只融合·同调·超量·连接怪兽为对象才能发动。那只怪兽除外或在自己场上特殊召唤。
-- ②：这张卡战斗破坏对方怪兽时才能发动。给与对方那只怪兽的原本攻击力和原本守备力之内较高方数值的伤害。
function c18666161.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，要求必须使用「死狱乡」卡组的卡作为融合素材，并且需要光属性和暗属性的怪兽各一张作为额外素材
	aux.AddFusionProcMix(c,false,true,aux.FilterBoolFunction(Card.IsFusionSetCard,0x164),c18666161.matfilter1,c18666161.matfilter2,nil)
	-- ①：自己·对方的主要阶段，以对方墓地1只融合·同调·超量·连接怪兽为对象才能发动。那只怪兽除外或在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18666161,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,18666161)
	e1:SetCondition(c18666161.effcon)
	e1:SetTarget(c18666161.efftg)
	e1:SetOperation(c18666161.effop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽时才能发动。给与对方那只怪兽的原本攻击力和原本守备力之内较高方数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18666161,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCountLimit(1,18666162)
	-- 设置效果的发动条件为：此卡正在与对方怪兽战斗且该怪兽被破坏
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(c18666161.damtg)
	e2:SetOperation(c18666161.damop)
	c:RegisterEffect(e2)
end
-- 过滤器函数，用于筛选光属性的融合素材
function c18666161.matfilter1(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT)
end
-- 过滤器函数，用于筛选暗属性的融合素材
function c18666161.matfilter2(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK)
end
-- 判断当前是否处于主要阶段1或主要阶段2
function c18666161.effcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 定义用于选择目标的过滤器函数，判断墓地中的怪兽是否为融合·同调·超量·连接怪兽，并且可以除外或特殊召唤
function c18666161.rmfilter(c,e,tp,check)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
		and (c:IsAbleToRemove() or check and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 设置效果的目标选择处理，选择对方墓地中的融合·同调·超量·连接怪兽作为对象
function c18666161.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断玩家场上是否有空位可用于特殊召唤
	local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c18666161.rmfilter(chkc,e,tp,check) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c18666161.rmfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp,check) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c18666161.rmfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,check)
end
-- 设置效果的处理流程，根据条件决定将目标怪兽除外或特殊召唤
function c18666161.effop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 检查目标怪兽是否受到「王家长眠之谷」保护，若受保护则无效效果
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 判断玩家场上是否有空位且目标怪兽可特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 若目标怪兽不能除外，则由玩家选择是特殊召唤还是除外
			and (not tc:IsAbleToRemove() or Duel.SelectOption(tp,1192,1152)==1) then
			-- 将目标怪兽特殊召唤到玩家场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将目标怪兽除外
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 设置伤害效果的目标处理，计算对方被破坏怪兽的攻击力与守备力的最大值作为伤害数值
function c18666161.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local dam=bc:GetBaseAttack()
	if bc:GetBaseAttack()<bc:GetBaseDefense() then dam=bc:GetBaseDefense() end
	if chk==0 then return dam>0 end
	-- 设置伤害效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害效果的目标伤害值
	Duel.SetTargetParam(dam)
	-- 设置伤害效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 设置伤害效果的处理流程，对目标玩家造成相应伤害
function c18666161.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和目标伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成相应数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
