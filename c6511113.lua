--フレシアの蟲惑魔
-- 效果：
-- 4星怪兽×2
-- ①：持有超量素材的这张卡不受陷阱卡的效果影响。
-- ②：只要这张卡在怪兽区域存在，「芙莉西亚之虫惑魔」以外的自己场上的「虫惑魔」怪兽不会被战斗·效果破坏，对方不能把那些作为效果的对象。
-- ③：自己·对方回合1次，把这张卡1个超量素材取除，从卡组把1张「洞」通常陷阱卡或「落穴」通常陷阱卡送去墓地才能发动。这个效果变成和那张陷阱卡发动时的效果相同。
function c6511113.initial_effect(c)
	-- 为这张卡添加超量召唤手续：4星怪兽2只。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：持有超量素材的这张卡不受陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(c6511113.imcon)
	e1:SetValue(c6511113.efilter)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，「芙莉西亚之虫惑魔」以外的自己场上的「虫惑魔」怪兽不会被战斗·效果破坏，对方不能把那些作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c6511113.imtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置不能成为对方卡的效果的对象。
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	-- ③：自己·对方回合1次，把这张卡1个超量素材取除，从卡组把1张「洞」通常陷阱卡或「落穴」通常陷阱卡送去墓地才能发动。这个效果变成和那张陷阱卡发动时的效果相同。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(6511113,0))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetHintTiming(0x3c0)
	e5:SetCountLimit(1)
	e5:SetCost(c6511113.cost)
	e5:SetTarget(c6511113.target)
	e5:SetOperation(c6511113.operation)
	c:RegisterEffect(e5)
end
-- 免疫效果的启用条件：自身拥有超量素材。
function c6511113.imcon(e)
	return e:GetHandler():GetOverlayCount()>0
end
-- 免疫效果的过滤函数：仅免疫陷阱卡的效果。
function c6511113.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP)
end
-- 保护效果的适用对象：自己场上「芙莉西亚之虫惑魔」以外的「虫惑魔」怪兽。
function c6511113.imtg(e,c)
	return c:IsSetCard(0x108a) and not c:IsCode(6511113)
end
-- 复制效果的发动代价处理：标记此效果在发动阶段，并返回true。
function c6511113.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤卡组中满足条件的「洞」通常陷阱卡或「落穴」通常陷阱卡。
function c6511113.filter(c)
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89) and c:IsAbleToGraveAsCost()
		and c:CheckActivateEffect(false,true,false)~=nil
end
-- 复制效果的发动准备：检查并扣除超量素材，将卡组的陷阱卡送去墓地，并复制该陷阱卡的发动（Target）效果。
function c6511113.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
			-- 检查卡组中是否存在可以送去墓地且能发动效果的「洞」或「落穴」通常陷阱卡。
			and Duel.IsExistingMatchingCard(c6511113.filter,tp,LOCATION_DECK,0,1,nil)
	end
	e:SetLabel(0)
	-- 给玩家发送选择卡片送去墓地的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足条件的「洞」或「落穴」通常陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c6511113.filter,tp,LOCATION_DECK,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 将选择的陷阱卡作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息，防止该效果被其他卡片直接连锁响应。
	Duel.ClearOperationInfo(0)
end
-- 复制效果的执行：获取暂存的陷阱卡效果，并执行该陷阱卡的效果处理（Operation）。
function c6511113.operation(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
