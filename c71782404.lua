--レッドアイズ・バーン
-- 效果：
-- 「真红眼烧灭」在1回合只能发动1张。
-- ①：自己场上的表侧表示的「真红眼」怪兽被战斗·效果破坏的场合，以破坏的那1只怪兽为对象才能发动。双方玩家受到那只怪兽的原本攻击力数值的伤害。
function c71782404.initial_effect(c)
	-- 「真红眼烧灭」在1回合只能发动1张。①：自己场上的表侧表示的「真红眼」怪兽被战斗·效果破坏的场合，以破坏的那1只怪兽为对象才能发动。双方玩家受到那只怪兽的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,71782404+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c71782404.target)
	e1:SetOperation(c71782404.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示被战斗或效果破坏、原本攻击力大于0、可以成为效果对象且当前存在于墓地或除外区的「真红眼」怪兽
function c71782404.cfilter(c,e,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
		and c:IsPreviousSetCard(0x3b) and c:GetBaseAttack()>0 and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果发动的目标选择与确认：检测并选择被破坏的「真红眼」怪兽作为对象，并设置给与双方伤害的操作信息
function c71782404.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c71782404.cfilter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(c71782404.cfilter,1,nil,e,tp) end
	-- 提示玩家选择作为效果对象的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local g=eg:FilterSelect(tp,c71782404.cfilter,1,1,nil,e,tp)
	-- 将选择的卡片设置为效果处理的对象
	Duel.SetTargetCard(g)
	-- 设置操作信息，表示该效果会给与双方玩家相当于对象怪兽原本攻击力数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,g:GetFirst():GetBaseAttack())
end
-- 效果处理：给与双方玩家相当于对象怪兽原本攻击力数值的伤害
function c71782404.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的连锁中作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 给与对方玩家相当于该怪兽原本攻击力数值的伤害（分步处理）
		Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT,true)
		-- 给与自己玩家相当于该怪兽原本攻击力数值的伤害（分步处理）
		Duel.Damage(tp,tc:GetBaseAttack(),REASON_EFFECT,true)
		-- 完成分步伤害处理，触发伤害结算时点
		Duel.RDComplete()
	end
end
