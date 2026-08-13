--クイーンマドルチェ・ティアラフレース
-- 效果：
-- 5星「魔偶甜点」怪兽×3
-- 「魔偶甜点后·后冠草莓提拉米苏」1回合1次也能在自己场上的「魔偶甜点后·后冠提拉米苏」上面重叠来超量召唤。
-- ①：对方回合1次，把这张卡1个超量素材取除，以自己墓地最多2张「魔偶甜点」卡为对象才能发动。那些卡回到卡组，让最多有回去数量的对方场上的卡回到卡组。
-- ②：这张卡被对方破坏送去墓地的场合发动。这张卡回到额外卡组。
local s,id,o=GetID()
-- 初始化卡牌效果：登记关联卡名，设置「魔偶甜点」5星怪兽×3的超量召唤手续以及可在自己场上的「魔偶甜点后·后冠提拉米苏」上重叠进行超量召唤的附加手续（1回合1次），并注册①的对方回合取除素材回卡组效果和②的被对方破坏回额外卡组效果。
function s.initial_effect(c)
	-- 将卡号37164373（魔偶甜点后·后冠提拉米苏）加入本卡的关联卡名列表，用于判定卡名记载或系列关联。
	aux.AddCodeList(c,37164373)
	aux.AddXyzProcedure(c,s.mfilter,5,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)  --"是否在自己场上的「魔偶甜点后·后冠提拉米苏」上面重叠？"
	c:EnableReviveLimit()
	-- ①：对方回合1次，把这张卡1个超量素材取除，以自己墓地最多2张「魔偶甜点」卡为对象才能发动。那些卡回到卡组，让最多有回去数量的对方场上的卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"回到卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.tdcon)
	e1:SetCost(s.tdcost)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏送去墓地的场合发动。这张卡回到额外卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"回到额外卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.retcon)
	e2:SetTarget(s.rettg)
	e2:SetOperation(s.retop)
	c:RegisterEffect(e2)
end
-- 超量召唤素材的筛选条件：素材怪兽必须是「魔偶甜点」系列（SetCard 0x71）。
function s.mfilter(c)
	return c:IsSetCard(0x71)
end
-- 附加超量召唤手续中可重叠对象的判定：以自己场上表侧表示的「魔偶甜点后·后冠提拉米苏」（卡号37164373）为重叠素材。
function s.ovfilter(c)
	return c:IsFaceup() and c:IsCode(37164373)
end
-- 特殊叠放召唤的额外处理：限制1回合1次。在合法性检查时确认本回合尚未使用过此叠放方式；正式执行时为玩家注册一个结束阶段重置的誓约标记，防止本回合再次通过此方式超量召唤。
function s.xyzop(e,tp,chk)
	-- 检查当前操作是否为合法性检查（chk==0），且该玩家本回合未使用过该叠放方式（Duel.GetFlagEffect(tp,id)==0），满足才允许发动。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 为玩家tp注册编号为id的誓约标记，持续到结束阶段，用于记录本回合已使用过在「魔偶甜点后·后冠提拉米苏」上重叠的超量召唤方式。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- ①效果的发动条件函数：仅在对方回合才能发动。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家不是自己（即当前为对方回合）。
	return Duel.GetTurnPlayer()~=tp
end
-- ①效果的发动代价：将这张卡的1个超量素材取除。合法性检查时确认有素材可取，正式执行时移除1个超量素材（REASON_COST）。
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 墓地对象卡的筛选条件：是「魔偶甜点」系列卡（0x71）且可以回到卡组。
function s.filter(c)
	return c:IsSetCard(0x71) and c:IsAbleToDeck()
end
-- ①效果的目标处理：取对象效果，在自己墓地选择1~2张满足s.filter的「魔偶甜点」卡；同时需要确认对方场上有至少1张能回卡组的卡，以满足后续“最多有回去数量”的处理。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc) end
	-- 合法性检查：自己墓地是否存在至少1张满足条件的「魔偶甜点」卡可作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil)
		-- 合法性检查（续）：对方场上有至少1张能被送回卡组的卡，保证效果处理时“让最多有回去数量的对方场上的卡回到卡组”至少能有候选。
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示选择提示“请选择要返回卡组的卡”，引导玩家选择自己墓地要返回卡组的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择1~2张满足s.filter的「魔偶甜点」卡作为效果对象，并登记为当前连锁的目标。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,2,nil)
	-- 设置连锁操作信息：本次效果类别为回卡组（CATEGORY_TODECK），对象为选中的卡组g，数量为g的数量，供相关卡（如星尘龙）侦查。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- ①效果处理：将对象卡送回卡组并洗牌，统计实际回去的卡数ct；然后从对方场上选择最多ct张能回卡组的卡送回卡组并洗牌。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡组，筛选出与效果仍有关联的卡（排除已失效或离场的对象）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 把筛选后的对象卡送回持有者卡组并洗牌，执行‘那些卡回到卡组’。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_HAND+LOCATION_EXTRA)
	-- 获取对方场上所有能被送回卡组的卡，作为之后让对方卡片回卡组的候选集合。
	local dg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	if ct>0 and dg:GetCount()>0 then
		-- 显示选择提示“请选择要返回卡组的卡”，用于选择对方场上要返回卡组的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local rg=dg:Select(tp,1,ct,nil)
		-- 显示被选中的对方卡片作为广义对象，并记录这些卡被选为对象。
		Duel.HintSelection(rg)
		-- 将选择的对方卡片送回持有者卡组并洗牌，执行‘让最多有回去数量的对方场上的卡回到卡组’。
		Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡被对方破坏并送去墓地，且破坏前由自己控制（IsPreviousControler(tp)）。
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- ②效果发动时的目标处理：不需要选择对象，只需登记操作信息，允许发动。
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：本次效果类别为回卡组（CATEGORY_TODECK），对象为该卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与效果有关联，则将其送回持有者额外卡组并洗牌。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡送回持有者额外卡组并洗牌（额外卡组亦通过卡组处理函数送回）。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
