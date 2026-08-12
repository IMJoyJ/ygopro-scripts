--クロニクル・ソーサレス
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：可以从自己墓地的怪兽属性的以下效果选择1个发动。
-- ●光：除「年代记女巫」外的1只「青眼白龙」或者1张有那个卡名记述的卡从卡组送去墓地。
-- ●暗：除「年代记女巫」外的1只「黑魔术师」或者1张有那个卡名记述的卡从卡组送去墓地。
function c54878729.initial_effect(c)
	-- 在卡片中注册记述了「青眼白龙」和「黑魔术师」的卡片密码，以便支持相关卡片的检索或检测。
	aux.AddCodeList(c,89631139,46986414)
	-- 这个卡名的效果1回合只能使用1次。①：可以从自己墓地的怪兽属性的以下效果选择1个发动。●光：除「年代记女巫」外的1只「青眼白龙」或者1张有那个卡名记述的卡从卡组送去墓地。●暗：除「年代记女巫」外的1只「黑魔术师」或者1张有那个卡名记述的卡从卡组送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54878729,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,54878729)
	e1:SetTarget(c54878729.target)
	e1:SetOperation(c54878729.operation)
	c:RegisterEffect(e1)
end
-- 定义过滤卡组中符合条件卡片的辅助函数。
function c54878729.filter(c,code)
	-- 过滤条件：非「年代记女巫」，且是指定卡（青眼白龙/黑魔术师）或记述了该卡名的卡，且能送去墓地。
	return not c:IsCode(54878729) and aux.IsCodeOrListed(c,code) and c:IsAbleToGrave()
end
-- 定义检查墓地怪兽属性与卡组对应卡片是否存在的辅助函数。
function c54878729.chkfunc(g,attr,tp,code)
	-- 检查墓地中是否存在指定属性的怪兽，且卡组中存在至少1张满足过滤条件的卡。
	return g:IsExists(Card.IsAttribute,1,nil,attr) and Duel.IsExistingMatchingCard(c54878729.filter,tp,LOCATION_DECK,0,1,nil,code)
end
-- 效果①的发动准备与目标选择函数，用于检测发动条件、让玩家选择要发动的效果分支并设置操作信息。
function c54878729.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地的所有怪兽卡。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	local b1=c54878729.chkfunc(g,ATTRIBUTE_LIGHT,tp,89631139)
	local b2=c54878729.chkfunc(g,ATTRIBUTE_DARK,tp,46986414)
	if chk==0 then return b1 or b2 end
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(54878729,1)  --"光"
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(54878729,2)  --"暗"
		opval[off-1]=2
		off=off+1
	end
	-- 让玩家选择要发动的效果分支（光属性或暗属性对应的效果）。
	local op=Duel.SelectOption(tp,table.unpack(ops))
	e:SetLabel(opval[op])
	-- 设置连锁处理的操作信息，表示此效果会将卡组的1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的实际处理函数，根据玩家选择的分支将对应的卡从卡组送去墓地。
function c54878729.operation(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	local code=89631139
	if opt==2 then code=46986414 end
	-- 在系统界面提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡。
	local g=Duel.SelectMatchingCard(tp,c54878729.filter,tp,LOCATION_DECK,0,1,1,nil,code)
	if g:GetCount()>0 then
		-- 将选中的卡因效果送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
