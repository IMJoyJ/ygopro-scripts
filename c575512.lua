--PSYフレーム・サーキット
-- 效果：
-- ①：自己场上有「PSY骨架」怪兽特殊召唤的场合才能发动。只用自己场上的「PSY骨架」怪兽为同调素材作同调召唤。
-- ②：自己的「PSY骨架」怪兽和对方怪兽进行战斗的伤害步骤开始时，把手卡1只「PSY骨架」怪兽丢弃才能发动。那只进行战斗的自己怪兽的攻击力直到回合结束时上升因为这个效果发动而丢弃的怪兽的攻击力数值。
function c575512.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上有「PSY骨架」怪兽特殊召唤的场合才能发动。只用自己场上的「PSY骨架」怪兽为同调素材作同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(575512,0))  --"用自己场上的「PSY骨架」怪兽为同调素材作同调召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c575512.sccon)
	e2:SetTarget(c575512.sctg)
	e2:SetOperation(c575512.scop)
	c:RegisterEffect(e2)
	-- ②：自己的「PSY骨架」怪兽和对方怪兽进行战斗的伤害步骤开始时，把手卡1只「PSY骨架」怪兽丢弃才能发动。那只进行战斗的自己怪兽的攻击力直到回合结束时上升因为这个效果发动而丢弃的怪兽的攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(575512,1))  --"攻击上升"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(c575512.atkcon)
	e3:SetCost(c575512.atkcost)
	e3:SetOperation(c575512.atkop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「PSY骨架」怪兽
function c575512.scfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xc1) and c:IsControler(tp)
end
-- 效果①的发动条件：检查特殊召唤成功的怪兽中是否存在自己场上的表侧表示「PSY骨架」怪兽
function c575512.sccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c575512.scfilter,1,nil,tp)
end
-- 效果①的发动检测与效果注册：检查是否存在仅以自己场上的「PSY骨架」怪兽为素材可以同调召唤的怪兽，并设置特殊召唤的操作信息
function c575512.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己场上可用于同调召唤的素材，并过滤出属于「PSY骨架」系列的怪兽
		local mg=Duel.GetSynchroMaterial(tp):Filter(Card.IsSetCard,nil,0xc1)
		-- 检查额外卡组是否存在可以使用上述「PSY骨架」怪兽作为素材进行同调召唤的怪兽
		return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil,mg)
	end
	-- 设置当前连锁的操作信息为：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的效果处理：让玩家选择1只可以同调召唤的怪兽，并仅以自己场上的「PSY骨架」怪兽为素材进行同调召唤
function c575512.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用于同调召唤的「PSY骨架」怪兽作为同调素材
	local mg=Duel.GetSynchroMaterial(tp):Filter(Card.IsSetCard,nil,0xc1)
	-- 获取额外卡组中仅以这些「PSY骨架」怪兽为素材可以进行同调召唤的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 让玩家以指定的「PSY骨架」怪兽组为素材，对选定的怪兽进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
-- 效果②的发动条件：伤害步骤开始时，进行战斗的自己怪兽是「PSY骨架」怪兽，且对方场上有进行战斗的怪兽
function c575512.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是对方的，则将目标怪兽切换为被攻击的自己怪兽
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	e:SetLabelObject(tc)
	-- 确认进行战斗的自己怪兽存在、属于「PSY骨架」系列、处于战斗状态，且对方场上有进行战斗的怪兽
	return tc and tc:IsControler(tp) and tc:IsSetCard(0xc1) and tc:IsRelateToBattle() and Duel.GetAttackTarget()~=nil
end
-- 过滤条件：手卡中攻击力大于0且可以丢弃的「PSY骨架」怪兽
function c575512.atkfilter(c)
	return c:IsSetCard(0xc1) and c:GetAttack()>0 and c:IsDiscardable()
end
-- 效果②的发动代价：从手卡将1只「PSY骨架」怪兽丢弃，并记录其攻击力数值
function c575512.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：检查手卡中是否存在满足丢弃条件的「PSY骨架」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c575512.atkfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家从手卡选择1只满足条件的「PSY骨架」怪兽
	local g=Duel.SelectMatchingCard(tp,c575512.atkfilter,tp,LOCATION_HAND,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetAttack())
	-- 将选中的怪兽作为发动代价丢弃送去墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 效果②的效果处理：使进行战斗的自己怪兽的攻击力直到回合结束时上升丢弃怪兽的攻击力数值
function c575512.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() and tc:IsFaceup() and tc:IsControler(tp) then
		-- 那只进行战斗的自己怪兽的攻击力直到回合结束时上升因为这个效果发动而丢弃的怪兽的攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
