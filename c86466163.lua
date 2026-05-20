--星因士 カペラ
-- 效果：
-- 「星因士 五车二」的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合才能发动。这个回合自己在用怪兽3只以上为素材的超量召唤的场合，可以把自己场上的4星以下的「星骑士」怪兽当作5星的素材使用。
function c86466163.initial_effect(c)
	-- 开启全局标记，用于支持限制超量素材数量的效果判定
	Duel.EnableGlobalFlag(GLOBALFLAG_XMAT_COUNT_LIMIT)
	-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合才能发动。这个回合自己在用怪兽3只以上为素材的超量召唤的场合，可以把自己场上的4星以下的「星骑士」怪兽当作5星的素材使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86466163,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,86466163)
	e1:SetOperation(c86466163.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	c86466163.star_knight_summon_effect=e1
end
-- 召唤·反转召唤·特殊召唤成功时，注册一个持续到回合结束的全局效果，用于改变超量素材的等级
function c86466163.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合自己在用怪兽3只以上为素材的超量召唤的场合，可以把自己场上的4星以下的「星骑士」怪兽当作5星的素材使用。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_XYZ_LEVEL)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c86466163.xyztg)
	e1:SetValue(c86466163.xyzlv)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将改变超量素材等级的效果注册给发动效果的玩家
	Duel.RegisterEffect(e1,tp)
end
-- 过滤出自己场上4星以下的「星骑士」怪兽
function c86466163.xyztg(e,c)
	return c:IsLevelBelow(4) and c:IsSetCard(0x9c)
end
-- 计算并返回怪兽作为超量素材时的等级
function c86466163.xyzlv(e,c,rc)
	-- 利用位运算拼接，使怪兽在进行3只以上素材的超量召唤时可以当作5星使用，同时保留其原本等级
	return 0x30050000|aux.GetCappedXyzLevel(c)
end
