--サークル・オブ・フェアリー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只昆虫族·植物族怪兽召唤。
-- ②：自己的昆虫族·植物族怪兽的战斗让怪兽被破坏送去墓地时，以那1只破坏的怪兽为对象才能发动。给与对方那只怪兽的攻击力一半数值的伤害。那之后，自己基本分回复给与的伤害的数值。
function c12954226.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只昆虫族·植物族怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12954226,0))  --"使用「仙女圆环」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 将①效果的适用对象限定为昆虫族·植物族怪兽，即只有这些种族能使用额外的一次通常召唤。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_INSECT+RACE_PLANT))
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己的昆虫族·植物族怪兽的战斗让怪兽被破坏送去墓地时，以那1只破坏的怪兽为对象才能发动。给与对方那只怪兽的攻击力一半数值的伤害。那之后，自己基本分回复给与的伤害的数值。
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
-- ②效果的发动条件判定：我方有昆虫族·植物族怪兽正在进行战斗，并且有怪兽因该战斗被破坏送去墓地。
function c12954226.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方当前正在战斗中的怪兽，用于判断是否为昆虫族·植物族怪兽。
	local a=Duel.GetBattleMonster(tp)
	return a and a:IsRace(RACE_INSECT+RACE_PLANT) and eg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
end
-- 筛选可作为②效果对象的卡：攻击力大于0、能成为效果对象、且在墓地的怪兽。
function c12954226.damfilter(c,e)
	return c:GetAttack()>0 and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_GRAVE)
end
-- ②效果发动时的对象选择与操作信息设定：若有符合条件的破坏怪兽则发动，并从其中选择1只（若只有1只则自动选择）作为效果对象；随后设置伤害与回复的操作信息。
function c12954226.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c12954226.filter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(c12954226.damfilter,1,nil,e) end
	local g=eg
	if #eg>1 then
		-- 弹出选择对象的提示消息，要求玩家选择效果的对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		g=eg:FilterSelect(tp,c12954226.damfilter,1,1,nil,e)
	end
	-- 将选择的那只怪兽设置为当前效果的对象。
	Duel.SetTargetCard(g)
	local value=e:GetHandler():GetAttack()/2
	-- 设置效果处理时会给对方造成伤害的操作信息，伤害数值为 value。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,value)
	-- 设置效果处理时自己会回复生命值的操作信息，回复数值为 value。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,value)
end
-- ②效果处理：给与对方对象怪兽攻击力一半数值的伤害；若造成实际伤害，则自己回复等量生命值。
function c12954226.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果对象（被破坏送去墓地的那只怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local value=tc:GetAttack()/2
		-- 给与对方玩家 value 点伤害；若实际造成伤害（返回值不为0）则继续执行。
		if Duel.Damage(1-tp,value,REASON_EFFECT)~=0 then
			-- 中断当前效果处理，使后续回复作为独立处理，对应原文的‘那之后’。
			Duel.BreakEffect()
			-- 自己回复 value 点生命值。
			Duel.Recover(tp,value,REASON_EFFECT)
		end
	end
end
