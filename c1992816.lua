--No.9 天蓋星ダイソン・スフィア
-- 效果：
-- 9星怪兽×2
-- ①：持有比这张卡高的攻击力的怪兽在对方场上存在的场合，自己主要阶段1把这张卡1个超量素材取除才能发动。这个回合，这张卡可以直接攻击。
-- ②：持有超量素材的这张卡被攻击的战斗步骤才能发动1次。那次攻击无效。
-- ③：这张卡没有超量素材的状态被选择作为攻击对象时，以自己墓地2只怪兽为对象才能发动。那些怪兽在这张卡下面重叠作为超量素材。
function c1992816.initial_effect(c)
	-- 为这张卡添加超量召唤手续：用任意2只9星怪兽叠放召唤（对应超量召唤条件‘9星怪兽×2’）。
	aux.AddXyzProcedure(c,nil,9,2)
	c:EnableReviveLimit()
	-- ②：持有超量素材的这张卡被攻击的战斗步骤才能发动1次。那次攻击无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1992816,0))  --"攻击无效"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_BATTLE_PHASE)
	e1:SetCondition(c1992816.atkcon)
	e1:SetCost(c1992816.atkcost)
	e1:SetOperation(c1992816.atkop)
	c:RegisterEffect(e1)
	-- ③：这张卡没有超量素材的状态被选择作为攻击对象时，以自己墓地2只怪兽为对象才能发动。那些怪兽在这张卡下面重叠作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1992816,1))  --"增加素材"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c1992816.olcon)
	e2:SetTarget(c1992816.oltg)
	e2:SetOperation(c1992816.olop)
	c:RegisterEffect(e2)
	-- ①：持有比这张卡高的攻击力的怪兽在对方场上存在的场合，自己主要阶段1把这张卡1个超量素材取除才能发动。这个回合，这张卡可以直接攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1992816,2))  --"直接攻击"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c1992816.dacon)
	e3:SetCost(c1992816.dacost)
	e3:SetOperation(c1992816.daop)
	c:RegisterEffect(e3)
end
-- 将卡号1992816登记为9阶超量怪兽（No.9），供No.卡相关规则与效果判定使用。
aux.xyz_number[1992816]=9
-- 效果②的发动条件判定：这张卡成为攻击对象且持有超量素材时允许发动。
function c1992816.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定这张卡正是当前被攻击的目标，并且其拥有超量素材。
	return e:GetHandler()==Duel.GetAttackTarget() and e:GetHandler():GetOverlayCount()~=0
end
-- 效果②的发动代价：通过标记flag来限制同一战斗步骤内只能发动1次（第一次发动前检查无标记，发动后设置标记，伤害阶段结束时重置）。
function c1992816.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(1992816)==0 end
	e:GetHandler():RegisterFlagEffect(1992816,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
end
-- 效果②处理：无效那次攻击。
function c1992816.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效当前进行的攻击，若攻击已被无效或攻击本身无法进行则返回false。
	Duel.NegateAttack()
end
-- 效果③的发动条件：这张卡被选择为攻击对象时，且处于没有超量素材的超量怪兽状态。
function c1992816.olcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()==0 and e:GetHandler():IsType(TYPE_XYZ)
end
-- 定义墓地怪兽可作为超量素材的条件：是怪兽且可以叠放在超量怪兽下面。
function c1992816.matfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 效果③发动时的目标选择与操作信息登记：从自己墓地选择2只可作为超量素材的怪兽为对象，并设定为离墓效果。
function c1992816.oltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c1992816.matfilter(chkc) end
	-- 合法性检查：自己墓地是否存在至少2只满足素材条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c1992816.matfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 弹出选择‘请选择要作为超量素材的卡’的提示，让玩家选择墓地怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 从自己墓地选择2只满足条件的怪兽，并将其登记为本连锁对象。
	local g=Duel.SelectTarget(tp,c1992816.matfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 登记操作信息：表示有2张卡片将离开墓地（涉及墓地，可被王家长眠之谷等对应）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,2,0,0)
end
-- 处理时筛选对象卡：需要仍在墓地且仍与效果关联、并且可以作为超量素材叠放。
function c1992816.olfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsCanOverlay()
end
-- 效果③处理：若此卡仍在场上且效果有效，将所选对象怪兽叠放在此卡下面作为超量素材。
function c1992816.olop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 取得本连锁的对象卡组，并过滤出仍然满足‘与效果关联且可作为超量素材’的卡片。
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c1992816.olfilter,nil,e)
		if g:GetCount()>0 then
			-- 将过滤后的怪兽作为超量素材叠放在这张卡下面。
			Duel.Overlay(c,g)
		end
	end
end
-- 判定怪兽是否为表侧表示且攻击力高于指定攻击力，用于①检测对方是否存在更高攻击力怪兽。
function c1992816.dafilter(c,atk)
	return c:IsFaceup() and c:GetAttack()>atk
end
-- 效果①的发动条件：当前为主要阶段1，且对方场上有表侧表示的攻击力高于此卡的怪兽存在。
function c1992816.dacon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是主要阶段1。
	return Duel.GetCurrentPhase()==PHASE_MAIN1
		-- 判定对方场上有满足‘表侧表示且攻击力高于这张卡’的怪兽存在。
		and Duel.IsExistingMatchingCard(c1992816.dafilter,tp,0,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack())
end
-- 效果①的发动代价：从这张卡上取除1个超量素材作为发动代价。
function c1992816.dacost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①处理：若此卡仍表侧表示且在场上、对方仍存在攻击力更高的怪兽，则赋予此卡本回合可以直接攻击的效果。
function c1992816.daop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e)
		-- 在效果处理时再次确认对方场上仍然存在攻击力更高的怪兽，以满足直接攻击赋予的条件。
		and Duel.IsExistingMatchingCard(c1992816.dafilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack()) then
		-- 这个回合，这张卡可以直接攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
