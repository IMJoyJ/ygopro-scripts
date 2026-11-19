--サークル・オブ・フェアリー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只昆虫族·植物族怪兽召唤。
-- ②：自己的昆虫族·植物族怪兽的战斗让怪兽被破坏送去墓地时，以那1只破坏的怪兽为对象才能发动。给与对方那只怪兽的攻击力一半数值的伤害。那之后，自己基本分回复给与的伤害的数值。
function c12954226.initial_effect(c)
	-- 为这张卡添加同调召唤手续：1只调整加上1只以上调整以外的怪兽。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只昆虫族·植物族怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12954226,0))  --"使用「仙女圆环」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 限制通过此额外召唤效果召唤的怪兽必须是昆虫族或植物族。
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
-- ②效果的发动条件判定：检查自己参与战斗的怪兽是否为昆虫族或植物族，且被战斗破坏的怪兽组中有存在于墓地的卡。
function c12954226.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上正在进行战斗的怪兽。
	local a=Duel.GetBattleMonster(tp)
	return a and a:IsRace(RACE_INSECT+RACE_PLANT) and eg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
end
-- 过滤函数：判断卡片当前攻击力是否大于0、位于墓地且能成为本效果的对象。
function c12954226.damfilter(c,e)
	return c:GetAttack()>0 and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_GRAVE)
end
-- ②效果的对象选择与目标处理函数：选取1只符合条件被战斗破坏送去墓地的怪兽作为对象，并申报给与对方一半攻击力伤害及自己回复等量基本分的操作信息。
function c12954226.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c12954226.damfilter(chkc,e) end
	if chk==0 then return eg:IsExists(c12954226.damfilter,1,nil,e) end
	local g=eg
	if #eg>1 then
		-- 向自己发送选择提示，提示玩家选择效果的对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		g=eg:FilterSelect(tp,c12954226.damfilter,1,1,nil,e)
	end
	-- 将选中的怪兽卡设为当前连锁的效果对象。
	Duel.SetTargetCard(g)
	local value=g:GetFirst():GetAttack()/2
	-- 设置操作信息：预计给与对方该怪兽攻击力一半数值的效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,value)
	-- 设置操作信息：预计使自己回复该怪兽攻击力一半数值的基本分。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,value)
end
-- ②效果的效果处理函数：若对象怪兽仍与效果有联系，则给与对方其攻击力一半的伤害，若实际造成伤害不为0则中断效果并回复自己相同数值的基本分。
function c12954226.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁指定的对象怪兽卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local value=tc:GetAttack()/2
		-- 给与对方玩家等于对象怪兽攻击力一半的效果伤害，并判断实际造成的伤害是否不为0。
		if Duel.Damage(1-tp,value,REASON_EFFECT)~=0 then
			-- 中断当前效果处理，使之后的回复基本分与前面的造成伤害视为不同时进行。
			Duel.BreakEffect()
			-- 使自己以效果回复与造成伤害等量数值的基本分。
			Duel.Recover(tp,value,REASON_EFFECT)
		end
	end
end
