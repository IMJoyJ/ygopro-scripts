--サークル・オブ・フェアリー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只昆虫族·植物族怪兽召唤。
-- ②：自己的昆虫族·植物族怪兽的战斗让怪兽被破坏送去墓地时，以那1只破坏的怪兽为对象才能发动。给与对方那只怪兽的攻击力一半数值的伤害。那之后，自己基本分回复给与的伤害的数值。
function c12954226.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只昆虫族·植物族怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12954226,0))  --"使用「仙女圆环」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置效果仅对昆虫族和植物族怪兽生效
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_INSECT+RACE_PLANT))
	c:RegisterEffect(e1)
	-- ②：自己的昆虫族·植物族怪兽的战斗让怪兽被破坏送去墓地时，以那1只破坏的怪兽为对象才能发动。给与对方那只怪兽的攻击力一半数值的伤害。那之后，自己基本分回复给与的伤害的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12954226,1))
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,12954226)
	e2:SetCondition(c12954226.damcon)
	e2:SetTarget(c12954226.damtg)
	e2:SetOperation(c12954226.damop)
	c:RegisterEffect(e2)
end
-- 判断是否满足效果发动条件，即自己场上正进行战斗的怪兽为昆虫族或植物族，并且有怪兽被战斗破坏送入墓地
function c12954226.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在战斗的怪兽
	local a=Duel.GetBattleMonster(tp)
	return a and a:IsRace(RACE_INSECT+RACE_PLANT) and eg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
end
-- 定义过滤函数，用于筛选可作为效果对象的墓地怪兽
function c12954226.damfilter(c,e)
	return c:GetAttack()>0 and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_GRAVE)
end
-- 设置效果的目标选择处理函数
function c12954226.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c12954226.filter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(c12954226.damfilter,1,nil,e) end
	local g=eg
	if #eg>1 then
		-- 向玩家提示选择效果对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		g=eg:FilterSelect(tp,c12954226.damfilter,1,1,nil,e)
	end
	-- 设置当前效果的目标卡片
	Duel.SetTargetCard(g)
	local value=e:GetHandler():GetAttack()/2
	-- 设置将要造成伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,value)
	-- 设置将要回复LP的操作信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,value)
end
-- 设置效果的发动处理函数
function c12954226.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local value=tc:GetAttack()/2
		-- 对对方造成目标怪兽攻击力一半的伤害
		if Duel.Damage(1-tp,value,REASON_EFFECT)~=0 then
			-- 中断当前效果处理，防止时点错乱
			Duel.BreakEffect()
			-- 回复自身等量LP
			Duel.Recover(tp,value,REASON_EFFECT)
		end
	end
end
