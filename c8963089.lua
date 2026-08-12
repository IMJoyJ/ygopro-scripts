--黎銘機ヘオスヴァローグ
-- 效果：
-- 机械族·光属性怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合才能发动。下个回合的准备阶段，把持有融合召唤效果的1张卡从自己墓地加入手卡。
-- ②：对方把魔法·陷阱卡的效果发动时，把自己场上1只表侧表示的机械族·光属性怪兽或者自己墓地2只机械族·光属性怪兽除外才能发动。那个发动无效。
local s,id,o=GetID()
-- 初始化函数，注册融合素材、召唤限制以及①②效果
function s.initial_effect(c)
	-- 设定融合召唤素材为2只光属性·机械族怪兽
	aux.AddFusionProcFunRep(c,s.matfilter,2,true)
	c:EnableReviveLimit()
	-- ①：这张卡融合召唤的场合才能发动。下个回合的准备阶段，把持有融合召唤效果的1张卡从自己墓地加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回收融合效果的卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：对方把魔法·陷阱卡的效果发动时，把自己场上1只表侧表示的机械族·光属性怪兽或者自己墓地2只机械族·光属性怪兽除外才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"发动无效"
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
-- 融合素材过滤：光属性且机械族的怪兽
function s.matfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE)
end
-- 效果①的发动条件：这张卡融合召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果①的效果处理：注册一个在下个回合准备阶段触发的延迟效果
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- ①：……下个回合的准备阶段，把持有融合召唤效果的1张卡从自己墓地加入手卡。②：对方把魔法·陷阱卡的效果发动时，把自己场上1只表侧表示的机械族·光属性怪兽或者自己墓地2只机械族·光属性怪兽除外才能发动。那个发动无效。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetOperation(s.thop2)
	e1:SetReset(RESET_PHASE+PHASE_STANDBY)
	-- 将延迟效果注册给发动效果①的玩家
	Duel.RegisterEffect(e1,tp)
end
-- 过滤墓地中具有融合召唤效果且可以加入手牌的卡
function s.thfilter(c)
	-- 检查卡片是否具有融合召唤的效果标志且能加入手牌
	return c:IsEffectProperty(aux.EffectPropertyFilter(EFFECT_FLAG_FUSION_SUMMON)) and c:IsAbleToHand()
end
-- 延迟效果的具体处理：从墓地将1张持有融合召唤效果的卡加入手牌
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 在界面上显示该卡发动的动画提示
	Duel.Hint(HINT_CARD,0,id)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1张满足过滤条件且不受王家之谷影响的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件：此卡未被战斗破坏，且对方发动了魔法·陷阱卡的效果，且该发动可以被无效
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身未被战破、对方发动魔陷效果、且该发动可被无效
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 过滤用于Cost除外的卡：场上表侧表示或墓地的光属性机械族怪兽
function s.rfilter(c)
	return c:IsFaceupEx() and c:IsAbleToRemoveAsCost()
		and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 检查除外Cost的组合是否合法：必须是墓地的2张卡，或者是场上的1张卡
function s.gcheck(g)
	return (#g==2 and g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==2
			or #g==1 and g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)==1)
end
-- 效果②的Cost处理：从场上除外1只或从墓地除外2只表侧表示的光属性机械族怪兽
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上和墓地中所有满足除外Cost条件的卡
	local g=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,nil)
	if chk==0 then return g:CheckSubGroup(s.gcheck,1,2) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,1,2)
	-- 将选中的卡作为Cost表侧表示除外
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 效果②的Target处理：设置发动无效的操作信息
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果分类为“无效发动”，目标为触发连锁的卡
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果②的效果处理：使该魔法·陷阱卡的效果发动无效
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的发动无效
	Duel.NegateActivation(ev)
end
