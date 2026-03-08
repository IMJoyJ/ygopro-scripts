--悪魔竜ブラック・デーモンズ・ドラゴン
-- 效果：
-- 6星「恶魔」通常怪兽＋「真红眼」通常怪兽
-- 自己对「恶魔龙 暗黑魔龙」1回合只能有1次特殊召唤。
-- ①：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
-- ②：融合召唤的这张卡进行战斗的战斗阶段结束时，以自己墓地1只「真红眼」通常怪兽为对象才能发动。给与对方为墓地的那只怪兽的原本攻击力数值的伤害。那之后，那只怪兽回到卡组。
function c45349196.initial_effect(c)
	c:SetSPSummonOnce(45349196)
	-- 添加融合召唤手续，使用满足mfilter1和mfilter2条件的怪兽各1只为融合素材
	aux.AddFusionProcFun2(c,c45349196.mfilter1,c45349196.mfilter2,true)
	c:EnableReviveLimit()
	-- ①：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCondition(c45349196.accon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：融合召唤的这张卡进行战斗的战斗阶段结束时，以自己墓地1只「真红眼」通常怪兽为对象才能发动。给与对方为墓地的那只怪兽的原本攻击力数值的伤害。那之后，那只怪兽回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c45349196.damcon)
	e2:SetTarget(c45349196.damtg)
	e2:SetOperation(c45349196.damop)
	c:RegisterEffect(e2)
end
c45349196.material_setcode=0x3b
-- 筛选融合素材1，必须是6星的恶魔族通常怪兽
function c45349196.mfilter1(c)
	return c:IsFusionSetCard(0x45) and c:IsFusionType(TYPE_NORMAL) and c:IsLevel(6)
end
-- 筛选融合素材2，必须是真红眼族通常怪兽
function c45349196.mfilter2(c)
	return c:IsFusionSetCard(0x3b) and c:IsFusionType(TYPE_NORMAL)
end
-- 判断是否为攻击或被攻击状态
function c45349196.accon(e)
	-- 判断是否为攻击或被攻击状态
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
-- 判断是否为融合召唤且已参与战斗
function c45349196.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:GetBattledGroupCount()>0
end
-- 筛选墓地中的真红眼族通常怪兽
function c45349196.filter(c)
	return c:IsSetCard(0x3b) and c:IsType(TYPE_NORMAL) and c:IsAbleToDeck()
end
-- 设置效果目标为墓地中的真红眼族通常怪兽，并设置伤害和回卡组的操作信息
function c45349196.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45349196.filter(chkc) end
	-- 检查是否有满足条件的墓地目标
	if chk==0 then return Duel.IsExistingTarget(c45349196.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的墓地目标怪兽
	local g=Duel.SelectTarget(tp,c45349196.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	local atk=g:GetFirst():GetBaseAttack()
	-- 设置将对对方造成伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
	-- 设置将目标怪兽送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 处理效果的发动与执行，包括造成伤害和送回卡组
function c45349196.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且造成伤害
	if tc:IsRelateToEffect(e) and Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)~=0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 将目标怪兽送回卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
