--大要塞クジラ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：场上有「海」存在的场合才能发动。这个回合，自己的水属性怪兽可以直接攻击。
-- ②：对方战斗阶段，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
-- ③：场上的这张卡被战斗·效果破坏的场合才能发动。从自己的卡组·墓地选1只战士族·水属性怪兽加入手卡或特殊召唤。
function c96546575.initial_effect(c)
	-- 记录这张卡关联「海」（卡片密码22702055）的卡片信息
	aux.AddCodeList(c,22702055)
	-- ①：场上有「海」存在的场合才能发动。这个回合，自己的水属性怪兽可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96546575,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,96546575)
	e1:SetCondition(c96546575.dacon)
	e1:SetTarget(c96546575.datg)
	e1:SetOperation(c96546575.daop)
	c:RegisterEffect(e1)
	-- ②：对方战斗阶段，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96546575,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_BATTLE_START)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,96546576)
	e2:SetCondition(c96546575.descon)
	e2:SetTarget(c96546575.destg)
	e2:SetOperation(c96546575.desop)
	c:RegisterEffect(e2)
	-- ③：场上的这张卡被战斗·效果破坏的场合才能发动。从自己的卡组·墓地选1只战士族·水属性怪兽加入手卡或特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(96546575,2))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_GRAVE_SPSUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,96546577)
	e3:SetCondition(c96546575.spcon)
	e3:SetTarget(c96546575.sptg)
	e3:SetOperation(c96546575.spop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件判定函数
function c96546575.dacon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家能否进入战斗阶段，且场上或作为场地存在「海」
	return Duel.IsAbleToEnterBP() and Duel.IsEnvironment(22702055)
end
-- 效果①的发动判定（Target）函数
function c96546575.datg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家本回合是否尚未注册过该直接攻击效果的标识
	if chk==0 then return Duel.GetFlagEffect(tp,96546575)==0 end
end
-- 效果①的运行（Operation）函数
function c96546575.daop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个卡名的①②③的效果1回合各能使用1次。①：场上有「海」存在的场合才能发动。这个回合，自己的水属性怪兽可以直接攻击。②：对方战斗阶段，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。③：场上的这张卡被战斗·效果破坏的场合才能发动。从自己的卡组·墓地选1只战士族·水属性怪兽加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c96546575.target)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局注册该直接攻击的字段效果
	Duel.RegisterEffect(e1,tp)
	-- 给玩家注册一个回合结束时重置的标识效果，防止重复发动
	Duel.RegisterFlagEffect(tp,96546575,RESET_PHASE+PHASE_END,0,1)
end
-- 过滤可以直接攻击的怪兽的条件函数（水属性）
function c96546575.target(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果②的发动条件判定函数
function c96546575.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方玩家的战斗阶段
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE and Duel.GetTurnPlayer()==1-tp
end
-- 效果②的发动判定与取对象（Target）函数
function c96546575.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查对方场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为“破坏选中的怪兽”
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的运行（Operation）函数
function c96546575.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏该怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果③的发动条件判定函数（场上的这张卡被战斗或效果破坏）
function c96546575.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤满足“战士族·水属性”且能加入手卡或特殊召唤的怪兽
function c96546575.spfilter(c,e,tp)
	-- 获取玩家场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_WATER) and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 效果③的发动判定（Target）函数
function c96546575.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或墓地中是否存在至少1只满足条件的战士族·水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c96546575.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为“从卡组或墓地特殊召唤1只怪兽”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果③的运行（Operation）函数
function c96546575.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组或墓地选择1只满足条件的战士族·水属性怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c96546575.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 重新获取玩家场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 判定是否只能加入手卡，或者在可以特殊召唤且有空位的情况下，玩家主动选择加入手卡（选项1190为“加入手卡”，1152为“特殊召唤”）
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选中的怪兽加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡片
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
