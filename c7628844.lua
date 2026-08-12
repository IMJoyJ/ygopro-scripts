--CNo.32 海咬龍シャーク・ドレイク・リバイス
-- 效果：
-- 5星怪兽×4
-- 这张卡也能把手卡1张魔法卡丢弃，在自己场上的4阶「鲨龙兽」超量怪兽上面重叠来超量召唤。
-- ①：自己·对方回合1次，把这张卡1个超量素材取除，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果无效，那个攻击力·守备力变成0。
-- ②：这张卡在同1次的战斗阶段中可以作2次攻击，向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
local s,id,o=GetID()
-- 注册卡片效果，包括重叠超量召唤手续、①效果（无效对方怪兽效果并使攻防变为0）、②效果（2次攻击和贯穿伤害）
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,5,4,s.ovfilter,aux.Stringid(id,0),4,s.xyzop)  --"是否在「鲨龙兽」超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：自己·对方回合1次，把这张卡1个超量素材取除，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果无效，那个攻击力·守备力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	-- 设置效果发动条件为不在伤害计算后（可在伤害步骤发动）
	e1:SetCondition(aux.dscon)
	e1:SetCost(s.discost)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- ②：这张卡在同1次的战斗阶段中可以作2次攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
end
-- 设定该卡为「No.32」怪兽
aux.xyz_number[id]=32
-- 过滤手卡中可丢弃的魔法卡
function s.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 过滤自己场上表侧表示的4阶「鲨龙兽」超量怪兽
function s.ovfilter(c)
	return c:IsFaceup() and c:IsRank(4) and c:IsSetCard(0x11b8)
end
-- 处理重叠超量召唤时的额外操作（丢弃1张手卡中的魔法卡）
function s.xyzop(e,tp,chk)
	-- 检查手卡中是否存在至少1张可丢弃的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择手卡中1张魔法卡丢弃
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_SPSUMMON+REASON_DISCARD)
end
-- ①效果的发动代价：取除这张卡的1个超量素材
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果的靶向目标选择：选择对方场上1只表侧表示的效果怪兽
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查已选择的对象是否仍是对方场上表侧表示且未被无效的效果怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateEffectMonsterFilter(chkc) end
	-- 检查对方场上是否存在至少1只可以被无效的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 玩家选择对方场上1只可以被无效的效果怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表明该效果包含无效卡片效果的操作
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ①效果的实际处理：使目标怪兽的效果无效，并将其攻击力与守备力变为0
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使和目标怪兽有关的连锁都无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果无效
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 那个攻击力·守备力变成0。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetValue(0)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e4)
	end
end
