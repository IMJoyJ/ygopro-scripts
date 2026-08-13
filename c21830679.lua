--クロック・ワイバーン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。这张卡的攻击力变成一半，在自己场上把1只「时钟衍生物」（电子界族·风·1星·攻/守0）特殊召唤。
function c21830679.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡召唤·特殊召唤成功的场合才能发动。这张卡的攻击力变成一半，在自己场上把1只「时钟衍生物」（电子界族·风·1星·攻/守0）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21830679,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,21830679)
	e1:SetTarget(c21830679.target)
	e1:SetOperation(c21830679.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 效果发动合法性检查：在判定是否满足发动条件时，确认自己场上有可用的主要怪兽区空格，且玩家能够特殊召唤「时钟衍生物」，满足条件才允许发动。
function c21830679.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格（用于后续特殊召唤衍生物）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家tp能否特殊召唤「时钟衍生物」（电子界族·风·1星·攻/守0）到自己场上，作为发动条件之一。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,21830680,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_WIND) end
	-- 设置操作信息为特殊召唤分类，表示本次效果处理会进行1只怪兽的特殊召唤；对象不确定（不取对象），处理玩家为tp。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	-- 设置操作信息包含衍生物生成分类，标记效果处理时会生成衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
-- 效果处理：先确认此卡仍与效果相关、表侧表示且不免疫此效果；然后将其攻击力变成一半；若此卡未受天邪鬼等反转增减效果影响，且自己场上仍有可用怪兽区空格，并能特殊召唤「时钟衍生物」，则在己方场上特殊召唤1只「时钟衍生物」。
function c21830679.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and not c:IsImmuneToEffect(e) then
		-- 这张卡的攻击力变成一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(c:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 判定此卡没有受到EFFECT_REVERSE_UPDATE（如天邪鬼）的倒置增减影响，且自己场上仍存在可用的主要怪兽区空格。
		if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 确认玩家tp当前仍能特殊召唤「时钟衍生物」，满足条件则继续执行特殊召唤。
			and Duel.IsPlayerCanSpecialSummonMonster(tp,21830680,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_WIND) then
			-- 生成1只「时钟衍生物」（卡号21830680）给tp玩家。
			local token=Duel.CreateToken(tp,21830680)
			-- 将生成的衍生物以表侧表示特殊召唤到tp玩家的场上。
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
