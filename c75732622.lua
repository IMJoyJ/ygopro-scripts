--トーチ・ゴーレム
-- 效果：
-- 这张卡不能通常召唤。通过在自己场上把2只「拷问衍生物」（恶魔族·暗·1星·攻/守0）攻击表示特殊召唤可以在对方场上特殊召唤。把这张卡特殊召唤的回合，自己不能通常召唤。
function c75732622.initial_effect(c)
	c:EnableReviveLimit()
	-- 通过在自己场上把2只「拷问衍生物」（恶魔族·暗·1星·攻/守0）攻击表示特殊召唤可以在对方场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP,1)
	e1:SetCondition(c75732622.spcon)
	e1:SetOperation(c75732622.spop)
	c:RegisterEffect(e1)
	-- 把这张卡特殊召唤的回合，自己不能通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_COST)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCost(c75732622.spcost)
	e2:SetOperation(c75732622.spcop)
	c:RegisterEffect(e2)
end
-- 检查自身特殊召唤的条件是否满足（双方场上有足够的怪兽区域空位，且可以特殊召唤衍生物）
function c75732622.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上的怪兽区域空位数是否大于等于2，且对方场上可供自己使用的怪兽区域空位数是否大于0
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家是否可以进行2次特殊召唤
		and Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查玩家是否可以特殊召唤满足「拷问衍生物」属性的怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,75732623,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_ATTACK)
end
-- 执行特殊召唤2只「拷问衍生物」到自己场上的操作
function c75732622.spop(e,tp,eg,ep,ev,re,r,rp,c)
	for i=1,2 do
		-- 创建「拷问衍生物」卡片
		local token=Duel.CreateToken(tp,75732623)
		-- 将衍生物以表侧攻击表示特殊召唤到自己场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
	-- 完成特殊召唤的结算
	Duel.SpecialSummonComplete()
end
-- 检查本回合自己是否进行过通常召唤
function c75732622.spcost(e,c,tp)
	-- 返回本回合通常召唤的次数是否为0
	return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0
end
-- 注册本回合不能通常召唤（包括放置）的誓约效果
function c75732622.spcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 把这张卡特殊召唤的回合，自己不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 给玩家注册不能召唤怪兽的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 给玩家注册不能覆盖怪兽的效果
	Duel.RegisterEffect(e2,tp)
end
