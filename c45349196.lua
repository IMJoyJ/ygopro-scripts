--悪魔竜ブラック・デーモンズ・ドラゴン
-- 效果：
-- 6星「恶魔」通常怪兽＋「真红眼」通常怪兽
-- 自己对「恶魔龙 暗黑魔龙」1回合只能有1次特殊召唤。
-- ①：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
-- ②：融合召唤的这张卡进行战斗的战斗阶段结束时，以自己墓地1只「真红眼」通常怪兽为对象才能发动。给与对方为墓地的那只怪兽的原本攻击力数值的伤害。那之后，那只怪兽回到卡组。
function c45349196.initial_effect(c)
	c:SetSPSummonOnce(45349196)
	-- 为该卡添加融合召唤手续，融合素材必须各1只满足mfilter1和mfilter2的怪兽：即6星「恶魔」通常怪兽与「真红眼」通常怪兽。
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
-- 融合素材过滤条件1：作为融合素材时满足「恶魔」字段、是通常怪兽且等级为6（对应“6星「恶魔」通常怪兽”）。
function c45349196.mfilter1(c)
	return c:IsFusionSetCard(0x45) and c:IsFusionType(TYPE_NORMAL) and c:IsLevel(6)
end
-- 融合素材过滤条件2：作为融合素材时满足「真红眼」字段且是通常怪兽（对应“「真红眼」通常怪兽”）。
function c45349196.mfilter2(c)
	return c:IsFusionSetCard(0x3b) and c:IsFusionType(TYPE_NORMAL)
end
-- ①效果的发动条件：当这张卡是攻击怪兽或攻击对象时，即这张卡正在进行战斗的场合，该效果才能适用。
function c45349196.accon(e)
	-- 判断当前战斗的攻击者或攻击目标是否就是效果持有者：若是，则视为这张卡在进行战斗。
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
-- ②效果的发动条件：此卡以融合召唤方式出场，且本回合进行过战斗，满足“融合召唤的这张卡进行战斗的战斗阶段结束时”的发动时机。
function c45349196.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:GetBattledGroupCount()>0
end
-- ②效果选择对象的过滤条件：自己墓地的「真红眼」通常怪兽，且能够回到卡组。
function c45349196.filter(c)
	return c:IsSetCard(0x3b) and c:IsType(TYPE_NORMAL) and c:IsAbleToDeck()
end
-- ②效果发动时的目标选择：从自己墓地选择1只符合条件的「真红眼」通常怪兽作为对象，并记录伤害与回卡组的操作信息。
function c45349196.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45349196.filter(chkc) end
	-- 发动合法性检查：自己墓地存在至少1只符合条件的「真红眼」通常怪兽可供选择，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c45349196.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给出选择提示：请选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己墓地选择1只符合条件的「真红眼」通常怪兽，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c45349196.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	local atk=g:GetFirst():GetBaseAttack()
	-- 设置操作信息：效果处理时将对对方（1-tp）造成等于所选怪兽原本攻击力数值的伤害（伤害分类为CATEGORY_DAMAGE）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
	-- 设置操作信息：效果处理时将对象怪兽g送回卡组（分类为CATEGORY_TODECK），数量为1张。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ②效果处理：若对象怪兽仍与效果关联，则给与对方其原本攻击力数值的伤害；若伤害实际造成，则中断后将该怪兽洗回持有者卡组。
function c45349196.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的墓地「真红眼」通常怪兽对象。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果关联且给与对方的伤害实际成立（伤害值不为0），才继续处理“那之后”回卡组。
	if tc:IsRelateToEffect(e) and Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)~=0 then
		-- 中断当前效果处理，使伤害与回卡组作为不同时点的两个处理，避免错过时点并确保顺序。
		Duel.BreakEffect()
		-- 将对象怪兽送回持有者卡组并洗切，原因为效果处理（对应“那之后，那只怪兽回到卡组”）。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
