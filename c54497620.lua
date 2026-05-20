--ガジェット・ドライバー
-- 效果：
-- ①：把这张卡从手卡送去墓地，以自己场上的「变形斗士」怪兽任意数量为对象才能发动。那些自己的「变形斗士」怪兽的表示形式变更。这个效果在对方回合也能发动。
function c54497620.initial_effect(c)
	-- ①：把这张卡从手卡送去墓地，以自己场上的「变形斗士」怪兽任意数量为对象才能发动。那些自己的「变形斗士」怪兽的表示形式变更。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54497620,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c54497620.cost)
	e1:SetTarget(c54497620.tg)
	e1:SetOperation(c54497620.op)
	c:RegisterEffect(e1)
end
-- 定义效果发动的代价（Cost）函数，检查并执行将手卡的这张卡送去墓地
function c54497620.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将作为效果处理载体的这张卡作为代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：场上表侧表示的「变形斗士」怪兽
function c54497620.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x26)
end
-- 定义效果的目标（Target）函数，用于检测发动条件、选择对象并设置操作信息
function c54497620.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c54497620.filter(chkc) end
	-- 在发动阶段的检测中，确认自己场上是否存在至少1只表侧表示的「变形斗士」怪兽
	if chk==0 then return Duel.IsExistingTarget(c54497620.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 在客户端弹出提示信息，指导玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家选择自己场上任意数量（1到7只）表侧表示的「变形斗士」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c54497620.filter,tp,LOCATION_MZONE,0,1,7,nil)
	-- 向系统注册操作信息：改变所选怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 过滤条件：在效果处理时仍与该效果有关联且表侧表示的怪兽
function c54497620.tfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsFaceup()
end
-- 定义效果的处理（Operation）函数，将仍存在于场上的对象怪兽的表示形式变更
function c54497620.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段被选为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(c54497620.tfilter,nil,e)
	-- 将符合条件的对象怪兽的表示形式进行变更（表侧攻击表示与表侧守备表示互相转换）
	Duel.ChangePosition(sg,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
end
