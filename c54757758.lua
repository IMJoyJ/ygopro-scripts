--沼地のドロゴン
-- 效果：
-- 相同属性而种族不同的怪兽×2
-- ①：只要这张卡在怪兽区域存在，对方不能把这张卡以及持有和这张卡相同属性的场上的怪兽作为效果的对象。
-- ②：1回合1次，宣言1个属性才能发动。这张卡直到回合结束时变成宣言的属性。这个效果在对方回合也能发动。
function c54757758.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册融合召唤手续，需要2只满足过滤条件ffilter的怪兽作为素材
	aux.AddFusionProcFunRep(c,c54757758.ffilter,2,true)
	-- ①：只要这张卡在怪兽区域存在，对方不能把这张卡...作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	-- 设置不能成为对方卡片效果的对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，对方不能把...以及持有和这张卡相同属性的场上的怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c54757758.tglimit)
	-- 设置受影响的场上怪兽不能成为对方卡片效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ②：1回合1次，宣言1个属性才能发动。这张卡直到回合结束时变成宣言的属性。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(54757758,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c54757758.atttg)
	e3:SetOperation(c54757758.attop)
	c:RegisterEffect(e3)
end
-- 融合素材过滤函数：选择的素材必须是相同属性且不同种族的怪兽
function c54757758.ffilter(c,fc,sub,mg,sg)
	-- 如果还未选择其他素材，或者已选择的素材组为空，则允许选择任意怪兽
	return not sg or sg:FilterCount(aux.TRUE,c)==0
		or (sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute())
			and not sg:IsExists(Card.IsRace,1,c,c:GetRace()))
end
-- 过滤与这张卡属性相同的场上怪兽
function c54757758.tglimit(e,c)
	return c:IsAttribute(e:GetHandler():GetAttribute())
end
-- 属性变更效果的发动准备，让玩家宣言一个与当前不同的属性
function c54757758.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家从除自身当前属性以外的所有属性中宣言1个属性
	local aat=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~e:GetHandler():GetAttribute())
	e:SetLabel(aat)
end
-- 属性变更效果的执行，将这张卡的属性变更为宣言的属性
function c54757758.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡直到回合结束时变成宣言的属性。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
