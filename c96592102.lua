--RR－ブレード・バーナー・ファルコン
-- 效果：
-- 鸟兽族4星怪兽×2
-- ①：自己基本分比对方少3000以上，这张卡超量召唤成功的场合才能发动。这张卡的攻击力上升3000。
-- ②：这张卡战斗破坏对方怪兽时，把这张卡的超量素材任意数量取除才能发动。选取除的超量素材数量的对方场上的怪兽破坏。
function c96592102.initial_effect(c)
	-- 添加超量召唤手续：鸟兽族4星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WINDBEAST),4,2)
	c:EnableReviveLimit()
	-- ①：自己基本分比对方少3000以上，这张卡超量召唤成功的场合才能发动。这张卡的攻击力上升3000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96592102,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c96592102.atkcon)
	e1:SetOperation(c96592102.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽时，把这张卡的超量素材任意数量取除才能发动。选取除的超量素材数量的对方场上的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96592102,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置发动条件为自身战斗破坏对方怪兽并送去墓地
	e2:SetCondition(aux.bdocon)
	e2:SetCost(c96592102.descost)
	e2:SetTarget(c96592102.destg)
	e2:SetOperation(c96592102.desop)
	c:RegisterEffect(e2)
end
-- 定义效果①的发动条件判定函数
function c96592102.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己基本分是否比对方少3000以上，且自身是否为超量召唤成功
	return Duel.GetLP(tp)<=Duel.GetLP(1-tp)-3000 and e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 定义效果①的效果处理函数
function c96592102.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力上升3000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(3000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 定义效果②的代价处理函数
function c96592102.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 获取对方场上的怪兽数量，作为可取除超量素材数量的上限
	local rt=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	local ct=c:RemoveOverlayCard(tp,1,rt,REASON_COST)
	e:SetLabel(ct)
end
-- 定义效果②的目标选择与发动准备函数
function c96592102.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查对方场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有的怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置破坏操作信息，数量为作为代价取除的超量素材数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,e:GetLabel(),0,0)
end
-- 定义效果②的效果处理函数
function c96592102.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择与取除的超量素材数量相同的对方场上的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,ct,ct,nil)
	if g:GetCount()>0 then
		-- 在场上显式框选提示被选中的怪兽
		Duel.HintSelection(g)
		-- 破坏选中的怪兽
		Duel.Destroy(g,REASON_EFFECT)
	end
end
