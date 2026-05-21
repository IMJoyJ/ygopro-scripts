--相剣軍師－龍淵
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡其他的1张「相剑」卡或者1只幻龙族怪兽丢弃才能发动。这张卡从手卡特殊召唤。那之后，可以在自己场上把1只「相剑衍生物」（幻龙族·调整·水·4星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：这张卡作为同调素材送去墓地的场合才能发动。给与对方1200伤害。
function c93490856.initial_effect(c)
	-- ①：把手卡其他的1张「相剑」卡或者1只幻龙族怪兽丢弃才能发动。这张卡从手卡特殊召唤。那之后，可以在自己场上把1只「相剑衍生物」（幻龙族·调整·水·4星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93490856,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,93490856)
	e1:SetCost(c93490856.spcost)
	e1:SetTarget(c93490856.sptg)
	e1:SetOperation(c93490856.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为同调素材送去墓地的场合才能发动。给与对方1200伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93490856,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,93490857)
	e2:SetCondition(c93490856.damcon)
	e2:SetTarget(c93490856.damtg)
	e2:SetOperation(c93490856.damop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中除自身以外的「相剑」卡片或幻龙族怪兽，且该卡可以被丢弃
function c93490856.costfilter(c)
	return (c:IsSetCard(0x16b) or (c:IsRace(RACE_WYRM) and c:IsType(TYPE_MONSTER))) and c:IsDiscardable()
end
-- 效果①的发动代价：丢弃手卡中1张「相剑」卡或1只幻龙族怪兽
function c93490856.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除自身以外的「相剑」卡片或幻龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c93490856.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家选择手卡中1张满足条件的卡丢弃
	Duel.DiscardHand(tp,c93490856.costfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 效果①的发动准备：检查怪兽区域是否有空位，以及自身是否可以特殊召唤
function c93490856.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有怪兽区域的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：特殊召唤自身，并可选特殊召唤1只「相剑衍生物」，同时为该衍生物添加额外卡组特招限制
function c93490856.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于手卡，则将其特殊召唤，并判断是否特殊召唤成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取自己场上可用的怪兽区域空格数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检查场上是否有空位，且玩家是否可以特殊召唤指定的「相剑衍生物」
		if ft>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,20001444,0x16b,TYPES_TOKEN_MONSTER+TYPE_TUNER,0,0,4,RACE_WYRM,ATTRIBUTE_WATER)
			-- 询问玩家是否选择特殊召唤衍生物
			and Duel.SelectYesNo(tp,aux.Stringid(93490856,2)) then  --"是否特殊召唤衍生物？"
				-- 中断当前效果处理，使后续的特殊召唤衍生物与特殊召唤自身不视为同时处理
				Duel.BreakEffect()
				-- 创建「相剑衍生物」卡片数据
				local token=Duel.CreateToken(tp,93490857)
				-- 将衍生物以表侧表示特殊召唤到自己场上（分步处理）
				Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
				-- 只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。②：这张卡作为同调素材送去墓地的场合才能发动。给与对方1200伤害。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e1:SetRange(LOCATION_MZONE)
				e1:SetAbsoluteRange(tp,1,0)
				e1:SetTarget(c93490856.splimit)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				token:RegisterEffect(e1,true)
				-- 完成衍生物的特殊召唤流程
				Duel.SpecialSummonComplete()
		end
	end
end
-- 限制玩家不能从额外卡组特殊召唤同调怪兽以外的怪兽
function c93490856.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果②的发动条件：此卡作为同调素材送去墓地
function c93490856.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 效果②的发动准备：设置对方玩家为效果对象，并设置伤害数值为1200
function c93490856.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的对象玩家设为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将效果的对象参数（伤害值）设为1200
	Duel.SetTargetParam(1200)
	-- 设置连锁的操作信息为给与对方1200点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1200)
end
-- 效果②的效果处理：给与对方1200点伤害
function c93490856.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成相应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
