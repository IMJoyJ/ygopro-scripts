--リンクスレイヤー
-- 效果：
-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：1回合1次，把最多2张手卡丢弃，以丢弃数量的场上的魔法·陷阱卡为对象才能发动。那些卡破坏。
function c35595518.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c35595518.spcon)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把最多2张手卡丢弃，以丢弃数量的场上的魔法·陷阱卡为对象才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35595518,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c35595518.cost)
	e2:SetTarget(c35595518.target)
	e2:SetOperation(c35595518.operation)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判断函数：c为空时视为满足规则特殊召唤条件；否则需确认自己场上没有怪兽且主要怪兽区有空位，才能从手卡进行特殊召唤。
function c35595518.spcon(e,c)
	if c==nil then return true end
	-- 检查这张卡的控制者场上主要怪兽区域（LOCATION_MZONE）的怪兽数量为0，即自己场上没有怪兽存在。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 并且确认控制者主要怪兽区域存在可用的空格，以满足特殊召唤所需的场地条件。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- ②效果的发动代价处理：先检查手牌中是否有可丢弃的卡；再统计双方场上魔法·陷阱卡的数量作为最多可丢弃数（上限2）；随后从手牌丢弃1～rt张卡作为代价，并把实际丢弃张数存入效果的Label，供Target阶段选择等量对象。
function c35595518.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认自己的手牌中至少存在1张可以丢弃的卡，以满足“丢弃手卡”的发动代价。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 统计双方场上（LOCATION_ONFIELD）存在的魔法·陷阱卡数量，作为本次最多可丢弃手卡的数量上限（超过2则取2）。
	local rt=Duel.GetTargetCount(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	if rt>2 then rt=2 end
	-- 执行丢弃手卡的代价：从手牌选择1～rt张卡以“丢弃+代价”原因丢弃，并将实际丢弃数量记录在效果的Label中，用于后续选择相同数量的破坏对象。
	local ct=Duel.DiscardHand(tp,nil,1,rt,REASON_DISCARD+REASON_COST)
	e:SetLabel(ct)
end
-- ②效果的目标选择处理：验证发动时是否存在可取对象的魔法·陷阱卡；读取Cost阶段实际丢弃的张数ct；提示玩家选择ct张场上的魔法·陷阱卡作为对象，并设置操作信息为破坏这些卡。
function c35595518.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 发动合法性检查：确认场上存在至少1张可以作为效果对象的魔法·陷阱卡（因为Cost阶段已经丢弃了至少1张手卡）。
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	local ct=e:GetLabel()
	-- 向当前玩家发送选择消息提示，内容为“请选择要破坏的卡”（HINTMSG_DESTROY）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择ct张魔法·陷阱卡作为效果对象，选择数量等于实际丢弃的手卡数量，并自动将这些卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置本连锁的操作信息：声明将要破坏这些对象卡，破坏数量为ct，供其他效果（如星尘龙等）进行对应检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
end
-- ②效果处理时的破坏操作：从当前连锁信息中取出对象卡组，过滤出仍然与效果有联系的卡，若存在则将它们全部破坏。
function c35595518.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取Target阶段选择的对象卡组（CHAININFO_TARGET_CARDS）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if rg:GetCount()>0 then
		-- 将过滤后仍与效果关联的对象卡以“效果”原因全部破坏。
		Duel.Destroy(rg,REASON_EFFECT)
	end
end
