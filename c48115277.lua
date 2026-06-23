--ブロックマン
-- 效果：
-- ①：把这张卡解放才能发动。和这张卡在自己场上表侧表示存在的自己回合数相同数量的「积木衍生物」（岩石族·地·4星·攻1000/守1500）在自己场上守备表示特殊召唤。这衍生物不能攻击宣言。
function c48115277.initial_effect(c)
	-- ①：把这张卡解放才能发动。和这张卡在自己场上表侧表示存在的自己回合数相同数量的「积木衍生物」（岩石族·地·4星·攻1000/守1500）在自己场上守备表示特殊召唤。这衍生物不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e1:SetCondition(c48115277.regcon)
	e1:SetOperation(c48115277.regop)
	c:RegisterEffect(e1)
	-- 把这张卡解放才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48115277,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c48115277.spcost)
	e2:SetTarget(c48115277.sptg)
	e2:SetOperation(c48115277.spop)
	c:RegisterEffect(e2)
end
-- 判断是否为自己的回合开始阶段
function c48115277.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家等于效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 记录自己回合数，用于后续特殊召唤衍生物数量计算
function c48115277.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetFlagEffectLabel(48115277)
	if not ct then
		c:RegisterFlagEffect(48115277,RESET_EVENT+RESETS_STANDARD,0,1,0)
	else
		c:SetFlagEffectLabel(48115277,ct+1)
	end
end
-- 支付特殊召唤的代价：解放自身
function c48115277.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	local ct=e:GetHandler():GetFlagEffectLabel(48115277)
	if not ct then ct=0 end
	e:SetLabel(ct)
	-- 将自身从场上解放作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 设置特殊召唤目标：判断是否可以特殊召唤指定数量的衍生物
function c48115277.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=e:GetHandler():GetFlagEffectLabel(48115277)
		if not ct then ct=0 end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return (ct==0 or not Duel.IsPlayerAffectedByEffect(tp,59822133))
			-- 检测场上是否有足够空位来特殊召唤衍生物
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>ct-1
			-- 检测玩家是否可以特殊召唤指定参数的衍生物
			and Duel.IsPlayerCanSpecialSummonMonster(tp,48115278,0,TYPES_TOKEN_MONSTER,1000,1500,4,RACE_ROCK,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE)
	end
	local ct=e:GetLabel()
	-- 设置连锁操作信息：衍生物数量
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ct+1,0,0)
	-- 设置连锁操作信息：特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct+1,0,0)
end
-- 执行特殊召唤操作：根据记录的回合数召唤相应数量的衍生物，并赋予其不能攻击的效果
function c48115277.spop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ct>0 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检测场上是否有足够空位来特殊召唤衍生物
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>ct
		-- 检测玩家是否可以特殊召唤指定参数的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,48115278,0,TYPES_TOKEN_MONSTER,1000,1500,4,RACE_ROCK,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) then
		for i=1,ct+1 do
			-- 创建一个指定编号的衍生物
			local token=Duel.CreateToken(tp,48115278)
			-- 将衍生物以守备表示形式特殊召唤到场上
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			-- 这衍生物不能攻击宣言。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
		end
		-- 完成一次完整的特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
