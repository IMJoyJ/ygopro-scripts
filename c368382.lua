--ダイナミスト・ブラキオン
-- 效果：
-- ←6 【灵摆】 6→
-- ①：只在这张卡在灵摆区域存在才有1次，可以把以这张卡以外的自己场上的「雾动机龙」卡为对象发动的效果无效。那之后，这张卡破坏。
-- 【怪兽效果】
-- ①：自己的怪兽区域没有「雾动机龙·腕龙」存在，场上的攻击力最高的怪兽在对方场上存在的场合，这张卡可以从手卡特殊召唤。
function c368382.initial_effect(c)
	-- 为这张卡添加灵摆怪兽的基本属性，使其作为灵摆卡可在灵摆区发动，并能进行灵摆召唤。
	aux.EnablePendulumAttribute(c)
	-- ←6 【灵摆】 6→ ①：只在这张卡在灵摆区域存在才有1次，可以把以这张卡以外的自己场上的「雾动机龙」卡为对象发动的效果无效。那之后，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c368382.negcon)
	e2:SetOperation(c368382.negop)
	c:RegisterEffect(e2)
	-- 【怪兽效果】①：自己的怪兽区域没有「雾动机龙·腕龙」存在，场上的攻击力最高的怪兽在对方场上存在的场合，这张卡可以从手卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c368382.spcon)
	c:RegisterEffect(e3)
end
-- 表侧表示且属于「雾动机龙」系列、由自己控制并存在于场上的卡的筛选函数，用于判断连锁对象中是否存在符合条件的「雾动机龙」卡。
function c368382.tfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xd8) and c:IsControler(tp) and c:IsOnField()
end
-- 灵摆效果的发动条件：本卡尚未用①效果、发动中的效果是取对象效果、且其对象包含此卡以外的自己场上表侧表示的「雾动机龙」卡，并且该连锁效果能够被无效且还未被无效。
function c368382.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁上效果的对象卡集合，用于后续检查对象中是否有满足条件的「雾动机龙」卡。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return e:GetHandler():GetFlagEffect(368382)==0 and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		and g and g:IsExists(c368382.tfilter,1,e:GetHandler(),tp)
		-- 确认该连锁效果可以被无效且当前未被无效，保证能对其发动无效效果。
		and Duel.IsChainDisablable(ev) and not Duel.IsChainDisabled(ev)
end
-- 灵摆效果的发动处理：询问玩家是否发动；若发动则为本卡设置已使用标记，若成功无效对象连锁，则先中断效果处理，再将此卡破坏。
function c368382.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示控制者选择是否发动本卡的灵摆效果（对应“可以把”）。
	if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		e:GetHandler():RegisterFlagEffect(368382,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 尝试无效对应的连锁效果，若无效成功则继续执行后续破坏处理。
		if Duel.NegateEffect(ev) then
			-- 中断当前效果处理，使后续的破坏不在同一时点处理，避免错过时点或造成不适配的连锁处理。
			Duel.BreakEffect()
			-- 以效果原因将这张灵摆卡破坏，对应“那之后，这张卡破坏”。
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end
-- 筛选表侧表示且卡号为368382的「雾动机龙·腕龙」的过滤函数，用于判断自己场上是否已存在同名卡。
function c368382.cfilter(c)
	return c:IsFaceup() and c:IsCode(368382)
end
-- 手卡特殊召唤规则效果的条件：自己场上没有表侧表示的同名「雾动机龙·腕龙」、双方场上有表侧表示怪兽且攻击力最高的怪兽在对方场上存在、自己的主要怪兽区有空位，满足时这张卡可以从手卡特殊召唤。
function c368382.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取双方场上所有表侧表示怪兽的集合，用于找出当前场上攻击力最高的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return false end
	local tg=g:GetMaxGroup(Card.GetAttack)
	-- 检查自己的主要怪兽区是否有可用的空格，确保从手卡特殊召唤时有空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上不存在表侧表示的「雾动机龙·腕龙」，满足“自己的怪兽区域没有「雾动机龙·腕龙」存在”的条件。
		and not Duel.IsExistingMatchingCard(c368382.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and tg:IsExists(Card.IsControler,1,nil,1-tp)
end
