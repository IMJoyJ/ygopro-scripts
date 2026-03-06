--幻獣機ヤクルスラーン
-- 效果：
-- 「幻兽机」调整＋调整以外的「幻兽机」怪兽1只以上
-- ①：这张卡同调召唤成功时，把自己场上的「幻兽机衍生物」任意数量解放才能发动。对方手卡随机选解放的数量丢弃。
-- ②：只要这张卡在怪兽区域存在，这张卡以外的自己场上的「幻兽机」怪兽不会被战斗·效果破坏。
-- ③：这张卡被对方破坏的场合才能发动。从卡组选1张速攻魔法卡在自己的魔法与陷阱区域盖放。
function c26949946.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整且为幻兽机族，以及1只以上调整以外的幻兽机族怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x101b),aux.NonTuner(Card.IsSetCard,0x101b),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功时，把自己场上的「幻兽机衍生物」任意数量解放才能发动。对方手卡随机选解放的数量丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26949946,0))  --"手卡破坏"
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c26949946.hdcon)
	e1:SetCost(c26949946.hdcost)
	e1:SetTarget(c26949946.hdtg)
	e1:SetOperation(c26949946.hdop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，这张卡以外的自己场上的「幻兽机」怪兽不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c26949946.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- ③：这张卡被对方破坏的场合才能发动。从卡组选1张速攻魔法卡在自己的魔法与陷阱区域盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(26949946,1))  --"卡组检索"
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(c26949946.setcon)
	e4:SetTarget(c26949946.settg)
	e4:SetOperation(c26949946.setop)
	c:RegisterEffect(e4)
end
-- 效果发动条件：此卡为同调召唤成功
function c26949946.hdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果发动费用：检查玩家场上是否存在至少1张「幻兽机衍生物」且对方手牌数量大于0
function c26949946.hdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张「幻兽机衍生物」
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsCode,1,nil,31533705)
		-- 检查对方手牌数量大于0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 获取对方手牌数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	-- 选择1至对方手牌数量张「幻兽机衍生物」进行解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsCode,1,ct,nil,31533705)
	e:SetLabel(g:GetCount())
	-- 将所选的「幻兽机衍生物」进行解放
	Duel.Release(g,REASON_COST)
end
-- 设置效果处理信息：对方手牌丢弃
function c26949946.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息：对方手牌丢弃
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,e:GetLabel())
end
-- 效果处理：对方随机丢弃与解放数量相等的手牌
function c26949946.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		local sg=g:RandomSelect(1-tp,e:GetLabel())
		-- 将所选手牌送去墓地
		Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
	end
end
-- 效果适用对象：自己场上的幻兽机族怪兽（不包括此卡）
function c26949946.indtg(e,c)
	return c:IsSetCard(0x101b) and c~=e:GetHandler()
end
-- 效果发动条件：此卡被对方破坏
function c26949946.setcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 检索过滤条件：速攻魔法卡
function c26949946.filter(c)
	return c:GetType()==TYPE_SPELL+TYPE_QUICKPLAY and c:IsSSetable()
end
-- 效果发动条件：场上存在可用魔法与陷阱区域且卡组存在速攻魔法卡
function c26949946.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可用魔法与陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组是否存在速攻魔法卡
		and Duel.IsExistingMatchingCard(c26949946.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理：从卡组选择1张速攻魔法卡盖放
function c26949946.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择1张速攻魔法卡
	local g=Duel.SelectMatchingCard(tp,c26949946.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选卡在自己场上盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
