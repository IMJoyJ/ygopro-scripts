--アームド・ドラゴン LV5
-- 效果：
-- ①：从手卡把1只怪兽送去墓地，以对方场上1只表侧表示怪兽为对象才能发动。持有为这个效果发动而送去墓地的怪兽的攻击力以下的攻击力的作为对象的对方怪兽破坏。
-- ②：这张卡战斗破坏怪兽的回合的结束阶段，把场上的这张卡送去墓地才能发动。从手卡·卡组把1只「武装龙 LV7」特殊召唤。
function c46384672.initial_effect(c)
	-- ②：这张卡战斗破坏怪兽的回合的结束阶段，把场上的这张卡送去墓地才能发动。从手卡·卡组把1只「武装龙 LV7」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c46384672.bdop)
	c:RegisterEffect(e1)
	-- ①：从手卡把1只怪兽送去墓地，以对方场上1只表侧表示怪兽为对象才能发动。持有为这个效果发动而送去墓地的怪兽的攻击力以下的攻击力的作为对象的对方怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46384672,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c46384672.descost)
	e2:SetTarget(c46384672.destg)
	e2:SetOperation(c46384672.desop)
	c:RegisterEffect(e2)
	-- ②：这张卡战斗破坏怪兽的回合的结束阶段，把场上的这张卡送去墓地才能发动。从手卡·卡组把1只「武装龙 LV7」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(46384672,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCondition(c46384672.spcon)
	e3:SetCost(c46384672.spcost)
	e3:SetTarget(c46384672.sptg)
	e3:SetOperation(c46384672.spop)
	c:RegisterEffect(e3)
end
c46384672.lvup={73879377}
c46384672.lvdn={980973}
-- 记录战斗破坏标志，用于判断是否满足效果②的发动条件
function c46384672.bdop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(46384672,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 过滤函数：检查手牌中是否存在可以作为cost送入墓地且能触发效果①的怪兽
function c46384672.cfilter(c,tp)
	local atk=c:GetAttack()
	if atk<0 then atk=0 end
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		-- 确保在对方场上存在攻击力小于等于被送去墓地怪兽攻击力的怪兽
		and Duel.IsExistingTarget(c46384672.dfilter,tp,0,LOCATION_MZONE,1,nil,atk)
end
-- 过滤函数：判断目标怪兽是否为表侧表示且攻击力小于等于指定值
function c46384672.dfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()<=atk
end
-- 效果①的cost处理：选择手牌中一只怪兽送入墓地，并记录其攻击力
function c46384672.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的怪兽用于发动效果①
	if chk==0 then return Duel.IsExistingMatchingCard(c46384672.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌中选择一只满足条件的怪兽并将其送去墓地
	local g=Duel.SelectMatchingCard(tp,c46384672.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	local atk=g:GetFirst():GetAttack()
	if atk<0 then atk=0 end
	e:SetLabel(atk)
	-- 将选中的怪兽送入墓地作为cost
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果①的目标选择处理：选择对方场上攻击力小于等于cost怪兽攻击力的怪兽
function c46384672.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c46384672.dfilter(chkc,e:GetLabel()) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的对方怪兽作为目标
	local g=Duel.SelectTarget(tp,c46384672.dfilter,tp,0,LOCATION_MZONE,1,1,nil,e:GetLabel())
	-- 设置操作信息，表示将要破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的处理：若目标怪兽满足条件则将其破坏
function c46384672.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:GetAttack()<=e:GetLabel() and tc:IsControler(1-tp) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断是否满足效果②的发动条件，即是否在战斗破坏怪兽后进入结束阶段
function c46384672.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(46384672)>0
end
-- 效果②的cost处理：将自身送去墓地作为cost
function c46384672.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为cost
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数：检查手牌或卡组中是否存在可特殊召唤的「武装龙 LV7」
function c46384672.spfilter(c,e,tp)
	return c:IsCode(73879377) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 效果②的目标选择处理：确认是否有足够的召唤位置和可用的「武装龙 LV7」
function c46384672.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查目标玩家场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手牌或卡组中是否存在可特殊召唤的「武装龙 LV7」
		and Duel.IsExistingMatchingCard(c46384672.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤「武装龙 LV7」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的处理：从手牌或卡组选择一只「武装龙 LV7」并特殊召唤
function c46384672.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查目标玩家场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或卡组中选择一只「武装龙 LV7」
	local g=Duel.SelectMatchingCard(tp,c46384672.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的「武装龙 LV7」特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
