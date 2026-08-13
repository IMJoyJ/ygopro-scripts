--門前払い
-- 效果：
-- ①：这张卡已在魔法与陷阱区域存在的状态，怪兽给与玩家战斗伤害的场合发动。那只怪兽回到持有者手卡。
function c20374520.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：这张卡已在魔法与陷阱区域存在的状态，怪兽给与玩家战斗伤害的场合发动。那只怪兽回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20374520,0))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c20374520.condition)
	e2:SetTarget(c20374520.target)
	e2:SetOperation(c20374520.operation)
	c:RegisterEffect(e2)
end
-- 发动条件判定：确认这张卡在魔法与陷阱区域处于效果有效状态（STATUS_EFFECT_ENABLED），以符合“这张卡已在魔法与陷阱区域存在的状态”。
function c20374520.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 触发效果发动时可执行的目标与操作信息设定：无特殊检查则允许发动；将造成战斗伤害的怪兽组设为对象，并声明将1只怪兽返回手卡。
function c20374520.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将造成战斗伤害的怪兽（eg中的怪兽）设置为当前连锁的广义对象，用于后续与效果关联性判定。
	Duel.SetTargetCard(eg)
	-- 设置操作信息：本次效果处理为将1只造成战斗伤害的怪兽返回持有者的手卡（CATEGORY_TOHAND），供其他卡进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,eg,1,0,0)
end
-- 效果处理：从造成战斗伤害的怪兽中取第一只，若该怪兽仍与当前效果关联（未离场或未脱离关系），则将其返回持有者手卡。
function c20374520.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsRelateToEffect(e) then
		-- 以效果（REASON_EFFECT）的原因为原因，将怪兽tc送回其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
