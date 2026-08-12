--雄炎星－スネイリン
-- 效果：
-- 1回合1次，名字带有「炎舞」的魔法·陷阱卡被送去自己墓地的场合，可以从卡组选1张名字带有「炎舞」的陷阱卡在自己场上盖放。此外，自己场上没有这张卡以外的怪兽存在的场合，1回合1次，把自己场上表侧表示存在的2张名字带有「炎舞」的魔法·陷阱卡送去墓地才能发动。从卡组抽1张卡。
function c75132317.initial_effect(c)
	-- 1回合1次，名字带有「炎舞」的魔法·陷阱卡被送去自己墓地的场合，可以从卡组选1张名字带有「炎舞」的陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75132317,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c75132317.setcon)
	e1:SetTarget(c75132317.settg)
	e1:SetOperation(c75132317.setop)
	c:RegisterEffect(e1)
	-- 此外，自己场上没有这张卡以外的怪兽存在的场合，1回合1次，把自己场上表侧表示存在的2张名字带有「炎舞」的魔法·陷阱卡送去墓地才能发动。从卡组抽1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75132317,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c75132317.drcon)
	e2:SetCost(c75132317.drcost)
	e2:SetTarget(c75132317.drtg)
	e2:SetOperation(c75132317.drop)
	c:RegisterEffect(e2)
end
-- 过滤送去墓地的卡：属于自己、名字带有「炎舞」的魔法·陷阱卡
function c75132317.tgfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 检查送去墓地的卡中是否存在满足过滤条件的卡
function c75132317.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c75132317.tgfilter,1,nil,tp)
end
-- 过滤卡组中满足条件的卡：名字带有「炎舞」的陷阱卡且可以盖放
function c75132317.filter(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 盖放效果的发动准备与合法性检测
function c75132317.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 第一阶段检测：此卡自身未在连锁中，且自己魔陷区有空位
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 且卡组中存在至少1张可以盖放的「炎舞」陷阱卡
		and Duel.IsExistingMatchingCard(c75132317.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 盖放效果的实际处理：从卡组选择1张「炎舞」陷阱卡在场上盖放
function c75132317.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张满足条件的「炎舞」陷阱卡
	local g=Duel.SelectMatchingCard(tp,c75132317.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡在自己场上盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 抽卡效果的发动条件：自己场上的怪兽数量为1（即只有这张卡本身）
function c75132317.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回自己场上的怪兽数量是否等于1
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
-- 过滤作为Cost送去墓地的卡：自己场上表侧表示的「炎舞」魔法·陷阱卡
function c75132317.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 抽卡效果的Cost处理（包含「炎星仙-鹫真人」的代替效果检测）
function c75132317.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 第一阶段检测：自己场上是否存在2张可送去墓地的「炎舞」魔陷
	if chk==0 then return Duel.IsExistingMatchingCard(c75132317.cfilter,tp,LOCATION_ONFIELD,0,2,nil)
		-- 检测【炎星仙-鹫真人】(46241344)的效果是否生效中。若在生效中，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
		or Duel.IsPlayerAffectedByEffect(tp,46241344) end
	-- 如果场上存在满足Cost条件的卡
	if Duel.IsExistingMatchingCard(c75132317.cfilter,tp,LOCATION_ONFIELD,0,2,nil)
		-- 检测【炎星仙-鹫真人】(46241344)的效果是否生效中。若在生效中，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
		and (not Duel.IsPlayerAffectedByEffect(tp,46241344) or not Duel.SelectYesNo(tp,aux.Stringid(46241344,0))) then  --"是否不把卡送去墓地发动？"
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家选择自己场上2张表侧表示的「炎舞」魔陷
		local g=Duel.SelectMatchingCard(tp,c75132317.cfilter,tp,LOCATION_ONFIELD,0,2,2,nil)
		-- 将选择的卡作为Cost送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	end
end
-- 抽卡效果的目标确认与操作信息设置
function c75132317.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 第一阶段检测：玩家当前是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果处理的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 向系统宣告此效果包含抽卡操作，数量为1，操作玩家为自己
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的实际处理
function c75132317.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
end
