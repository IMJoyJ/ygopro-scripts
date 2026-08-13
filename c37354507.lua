--忍者マスター SAIZO
-- 效果：
-- 「忍者」怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡所连接区有怪兽存在，这张卡不会成为攻击对象，也不会成为对方的效果的对象。
-- ②：自己主要阶段才能发动。从卡组选1张「忍法」魔法·陷阱卡在自己场上盖放。
function c37354507.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：必须用2只「忍者」怪兽作为连接素材，2只怪兽的连接召唤。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x2b),2,2)
	-- ②：自己主要阶段才能发动。从卡组选1张「忍法」魔法·陷阱卡在自己场上盖放。（这个卡名的②的效果1回合只能使用1次。）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37354507,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,37354507)
	e1:SetTarget(c37354507.settg)
	e1:SetOperation(c37354507.setop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡所连接区有怪兽存在，这张卡不会成为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c37354507.tgcon)
	-- 设置该效果的效果值为aux.imval1：当这张卡不免疫该效果时返回true，从而成为攻击对象的限制生效。
	e2:SetValue(aux.imval1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置该效果的效果值为aux.tgoval：当效果发动者为这张卡的控制者时返回true，即对方的卡不能选这张卡为效果对象。
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选出是「忍法」字段的魔法·陷阱卡，且能够盖放到魔法与陷阱区的卡。
function c37354507.setfilter(c)
	return c:IsSetCard(0x61) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ②效果的发动条件设定：在发动阶段检查自己卡组是否存在符合条件的「忍法」魔法·陷阱卡。
function c37354507.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时（chk==0），若卡组中存在至少1张符合条件的「忍法」魔法·陷阱卡则允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c37354507.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ②效果的处理：提示玩家选择要盖放的卡，从卡组选1张符合条件的「忍法」魔法·陷阱卡，然后盖放到自己场上。
function c37354507.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 给操作者发送选择提示消息，内容为“请选择要盖放的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张符合条件的「忍法」魔法·陷阱卡（此处使用Duel.SelectMatchingCard进行选择）。
	local g=Duel.SelectMatchingCard(tp,c37354507.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的那张「忍法」魔法·陷阱卡盖放到操作者自己场上。
		Duel.SSet(tp,g)
	end
end
-- ①效果的条件：检查这张卡的连接区是否存在怪兽，返回连接区怪兽数量>0，作为不会成为攻击对象/效果对象的适用条件。
function c37354507.tgcon(e)
	return e:GetHandler():GetLinkedGroupCount()>0
end
