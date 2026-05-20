--エコール・ド・ゾーン
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：回合玩家只对怪兽1只的召唤·反转召唤·特殊召唤成功的场合发动。那只怪兽破坏，那个控制者在那个自身场上把1只「假面衍生物」（魔法师族·暗·1星·攻/守?）特殊召唤。这衍生物攻击力·守备力变成和这个效果破坏的怪兽的各自数值相同，不能直接攻击。
-- ②：表侧表示的这张卡从场上离开的场合场上的「假面衍生物」全部破坏。
function c60514625.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：回合玩家只对怪兽1只的召唤·反转召唤·特殊召唤成功的场合发动。那只怪兽破坏，那个控制者在那个自身场上把1只「假面衍生物」（魔法师族·暗·1星·攻/守?）特殊召唤。这衍生物攻击力·守备力变成和这个效果破坏的怪兽的各自数值相同，不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60514625,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,60514625)
	e1:SetCondition(c60514625.tkcon)
	e1:SetTarget(c60514625.tktg)
	e1:SetOperation(c60514625.tkop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：表侧表示的这张卡从场上离开的场合场上的「假面衍生物」全部破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetOperation(c60514625.desop)
	c:RegisterEffect(e4)
end
-- 判定是否满足发动条件：仅有1只怪兽召唤·反转召唤·特殊召唤成功，且该怪兽的召唤玩家为当前的回合玩家。
function c60514625.tkcon(e,tp,eg,ep,ev,re,r,rp)
	if #eg~=1 then return false end
	local tc=eg:GetFirst()
	-- 判定召唤该怪兽的玩家是否为当前的回合玩家。
	return tc:IsSummonPlayer(Duel.GetTurnPlayer())
end
-- 效果发动的对象确认与操作信息注册（包含破坏、产生衍生物、特殊召唤）。
function c60514625.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=eg:GetFirst()
	-- 将召唤成功的怪兽设为当前效果的处理对象。
	Duel.SetTargetCard(eg)
	-- 设置连锁的操作信息为破坏该怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	-- 设置连锁的操作信息为产生衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁的操作信息为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理：破坏召唤的怪兽，并在其控制者场上特殊召唤「假面衍生物」，设置其攻守数值及限制直接攻击。
function c60514625.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:GetFirst()
	local p=tc:GetControler()
	-- 检查目标怪兽是否仍适用此效果，并尝试将其因效果破坏。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 检查该怪兽控制者的怪兽区域是否有空位。
		and Duel.GetLocationCount(p,LOCATION_MZONE)>0
		-- 检查该玩家是否能够特殊召唤指定的「假面衍生物」。
		and Duel.IsPlayerCanSpecialSummonMonster(p,60514626,0,TYPES_TOKEN_MONSTER,-2,-2,1,RACE_SPELLCASTER,ATTRIBUTE_DARK) then
		local atk=tc:GetPreviousAttackOnField()
		local def=tc:GetPreviousDefenseOnField()
		-- 创建「假面衍生物」的卡片数据。
		local token=Duel.CreateToken(tp,60514626)
		-- 尝试将衍生物以表侧表示特殊召唤到其控制者的场上（分步处理）。
		if Duel.SpecialSummonStep(token,0,p,p,false,false,POS_FACEUP) then
			-- 这衍生物攻击力·守备力变成和这个效果破坏的怪兽的各自数值相同
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_SET_DEFENSE)
			e2:SetValue(def)
			token:RegisterEffect(e2)
			-- 不能直接攻击。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e3)
		end
	end
	-- 完成特殊召唤的后续处理。
	Duel.SpecialSummonComplete()
end
-- 离场时的效果处理：将场上的「假面衍生物」全部破坏。
function c60514625.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsFacedown() then return end
	-- 获取双方场上所有的「假面衍生物」。
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,60514626)
	-- 将获取到的所有「假面衍生物」因效果破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
