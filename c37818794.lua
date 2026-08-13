--超魔導竜騎士－ドラグーン・オブ・レッドアイズ
-- 效果：
-- 「黑魔术师」＋「真红眼黑龙」或者龙族效果怪兽
-- ①：这张卡不会被效果破坏，双方不能把这张卡作为效果的对象。
-- ②：自己主要阶段才能发动（这个效果在1回合中可以使用最多有作为这张卡的融合素材的通常怪兽数量的次数）。对方场上1只怪兽破坏，给与对方那个原本攻击力数值的伤害。
-- ③：1回合1次，卡的效果发动时，丢弃1张手卡才能发动。那个发动无效并破坏，这张卡的攻击力上升1000。
function c37818794.initial_effect(c)
	-- 为这张卡添加融合召唤手续：融合素材为「黑魔术师」（46986414）1只，加上「真红眼黑龙」（74677422）或1只龙族效果怪兽，允许使用融合素材代用品。
	aux.AddFusionProcCodeFun(c,46986414,{74677422,c37818794.mfilter},1,true,true)
	c:EnableReviveLimit()
	-- 对应①效果原文：“双方不能把这张卡作为效果的对象。”设置这张卡在怪兽区域存在期间不能被双方作为效果对象的永续效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- 对应②效果原文：“自己主要阶段才能发动（这个效果在1回合中可以使用最多有作为这张卡的融合素材的通常怪兽数量的次数）。对方场上1只怪兽破坏，给与对方那个原本攻击力数值的伤害。”实现该起动效果的发动条件、目标选择与伤害处理。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37818794,0))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c37818794.descon)
	e3:SetTarget(c37818794.destg)
	e3:SetOperation(c37818794.desop)
	c:RegisterEffect(e3)
	-- 对应③效果原文：“1回合1次，卡的效果发动时，丢弃1张手卡才能发动。那个发动无效并破坏，这张卡的攻击力上升1000。”实现该诱发即时效果的发动条件、丢弃手卡代价、无效并破坏及攻击力上升。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(37818794,1))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c37818794.discon)
	e4:SetCost(c37818794.discost)
	e4:SetTarget(c37818794.distg)
	e4:SetOperation(c37818794.disop)
	c:RegisterEffect(e4)
	-- 对应②效果原文中“这个效果在1回合中可以使用最多有作为这张卡的融合素材的通常怪兽数量的次数”的次数限制机制：在融合召唤成功时记录可发动次数上限。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(c37818794.matcon)
	e5:SetOperation(c37818794.matop)
	c:RegisterEffect(e5)
	-- 对应②效果原文中“作为这张卡的融合素材的通常怪兽数量”的计算：在融合召唤前检查融合素材中通常怪兽的数量，供②效果使用次数限制参考。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_MATERIAL_CHECK)
	e6:SetValue(c37818794.valcheck)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
end
c37818794.material_setcode=0x3b
-- 检查融合素材组中是否存在「真红眼黑龙」（74677422），用于真红眼相关融合召唤的素材确认。
function c37818794.red_eyes_fusion_check(tp,sg,fc)
	return sg:IsExists(Card.IsFusionCode,1,nil,74677422)
end
-- 定义“龙族效果怪兽”的筛选条件：该怪兽为龙族且为效果怪兽，作为融合素材“龙族效果怪兽”的匹配条件。
function c37818794.mfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsFusionType(TYPE_EFFECT)
end
-- 效果②的发动条件：本卡带有“融合素材通常怪兽数量”标记（37818795）且该数量大于0。
function c37818794.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffectLabel(37818795) and e:GetHandler():GetFlagEffectLabel(37818795)>0
end
-- 效果②发动合法性检查：对方场上有怪兽，且本回合②效果已发动次数（flag 37818794）未达到素材通常怪兽数量上限（flag label 37818795）。
function c37818794.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 确认对方场上存在至少1只怪兽，作为效果②破坏目标的存在性判定。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
		and c:GetFlagEffect(37818794)<c:GetFlagEffectLabel(37818795) end
	c:RegisterFlagEffect(37818794,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	-- 获取对方场上的全部怪兽，作为效果②本次破坏可能涉及的目标集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：将本次效果登记为破坏效果，候选对象为对方场上全部怪兽，预计破坏1只。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：将本次效果登记为伤害效果，伤害对象为对方玩家；实际伤害数值在处理时根据被破坏怪兽的原本攻击力决定。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 效果②处理：从对方场上选择1只怪兽破坏，若破坏成功则给予对方该怪兽原本攻击力数值的伤害。
function c37818794.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要破坏的卡”的选择提示，要求玩家选择效果②的破坏对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让当前玩家从对方怪兽区域选择1只怪兽，作为效果②的破坏对象。
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		local atk=g:GetFirst():GetTextAttack()
		if atk<0 then atk=0 end
		-- 显示选中的卡为效果对象的动画，并将其标记为本连锁的效果对象。
		Duel.HintSelection(g)
		-- 以效果原因破坏所选怪兽；仅当破坏成功（返回值非0）时才继续处理后续伤害。
		if Duel.Destroy(g,REASON_EFFECT)~=0 then
			-- 给予对方玩家与被破坏怪兽原本攻击力数值相等的伤害（atk为该怪兽原本攻击力，小于0按0处理）。
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
-- 效果③的发动条件：本卡未被战斗破坏，且当前发动中的连锁可以被无效。
function c37818794.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查本卡未处于战斗破坏状态，且当前连锁的发动可以被无效，以满足效果③的发动条件。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 效果③的代价：从手卡丢弃1张卡；先确认手卡有可丢弃的卡，然后选择1张丢弃作为发动代价。
function c37818794.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认手卡存在至少1张可丢弃的卡，用于支付效果③的代价。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 弹出“请选择要丢弃的手牌”的选择提示，要求玩家选择要丢弃的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 从自己手卡中选择1张卡，作为发动效果③的代价。
	local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手卡送入墓地，原因标记为代价并丢弃（REASON_COST+REASON_DISCARD）。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 效果③的目标设置：以当前发动的效果为对象，设置无效该发动的操作信息；若该效果的发动物理卡可被破坏且仍与效果关联，则追加破坏该卡的操作信息。
function c37818794.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将当前连锁的发动登记为将被无效（无效对象为eg）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：当被无效效果的发动物理卡可破坏且仍关联时，将其登记为将被破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果③处理：无效该连锁的发动；若成功且对象卡可破坏则将其破坏；若本卡仍表侧表示在场，则攻击力上升1000。
function c37818794.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 复合条件：无效成功、被无效卡的发动物理卡仍与效果关联且破坏成功、本卡仍与效果关联并表侧表示在场，才执行攻击力上升。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 对应③效果原文“这张卡的攻击力上升1000”：创建使这张卡攻击力上升1000的效果，持续到离场或效果无效时重置。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- e5的触发条件：这张卡以融合召唤方式特殊召唤成功，且e5的label（素材通常怪兽数量）大于0。
function c37818794.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel()>0
end
-- 融合召唤成功时，将素材通常怪兽数量作为FlagEffect 37818795的值注册到这张卡上，用于②效果的发动次数上限。
function c37818794.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(37818795,RESET_EVENT+RESETS_STANDARD,0,1,e:GetLabel())
end
-- 素材检查时统计融合素材中的通常怪兽数量，并将数量保存到e5的label，供特殊召唤成功后的②效果次数限制使用。
function c37818794.valcheck(e,c)
	local g=c:GetMaterial()
	local ct=g:FilterCount(Card.IsFusionType,nil,TYPE_NORMAL)
	e:GetLabelObject():SetLabel(ct)
end
