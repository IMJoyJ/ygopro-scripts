--魔轟神トピー
-- 效果：
-- ①：自己手卡比对方少2张以上的场合，把手卡1只「魔轰神」怪兽给对方观看，把这张卡解放，以对方场上2张魔法·陷阱卡为对象才能发动。那些对方的卡破坏。
function c46833854.initial_effect(c)
	-- ①：自己手卡比对方少2张以上的场合，把手卡1只「魔轰神」怪兽给对方观看，把这张卡解放，以对方场上2张魔法·陷阱卡为对象才能发动。那些对方的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46833854,0))  --"对方场上存在的2张魔法·陷阱卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c46833854.con)
	e1:SetCost(c46833854.cost)
	e1:SetTarget(c46833854.tg)
	e1:SetOperation(c46833854.op)
	c:RegisterEffect(e1)
end
-- 效果发动条件：比较己方与对方的手牌数量，当对方手牌数减去己方手牌数不少于2时（即己方手牌比对方少2张以上），本效果满足发动条件。
function c46833854.con(e,tp,eg,ep,ev,re,r,rp)
	-- 计算差值：对方手牌数（Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)）减去己方手牌数（Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)），若差值≥2则返回真，表示“自己手卡比对方少2张以上”。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=2
end
-- 筛选条件：用于从手卡中找出可作为展示代价的「魔轰神」怪兽；要求卡名属于0x35（魔轰神）系列、是怪兽卡，且当前不处于公开状态。
function c46833854.cfilter(c)
	return c:IsSetCard(0x35) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 代价检查（chk==0）：确认效果发动者自身可以被解放，并且手牌中存在至少1张满足 cfilter 的「魔轰神」怪兽可供展示，只有两者同时满足才允许发动。
function c46833854.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable()
		-- 检查己方手牌中是否存在至少1张满足 cfilter 的卡（排除效果发动者自身），作为可供展示的「魔轰神」怪兽候补。
		and Duel.IsExistingMatchingCard(c46833854.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 发送选择提示：让当前玩家从手牌中选择一张卡，提示信息为“请选择给对方确认的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从己方手牌中选择1张满足 cfilter 的「魔轰神」怪兽卡（不选择效果发动者自身），作为将要给对方观看的卡。
	local g=Duel.SelectMatchingCard(tp,c46833854.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选中的手牌向对方玩家公开确认，完成效果中“给对方观看”的步骤。
	Duel.ConfirmCards(1-tp,g)
	-- 将效果发动者自身（这张「魔轰神 托比」）解放，作为发动效果的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
	-- 展示手牌后洗切己方手牌，避免手牌顺序信息泄露。
	Duel.ShuffleHand(tp)
end
-- 目标筛选条件：判断卡片是否为魔法卡或陷阱卡（TYPE_SPELL+TYPE_TRAP），用于选择对方场上的魔法·陷阱卡为破坏对象。
function c46833854.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 目标选择处理：若 chkc 参数存在，则单独验证该卡是否满足对象条件（对方场上、魔法/陷阱卡）；否则在发动时确认对方场上存在至少2张可被取对象的魔法·陷阱卡，然后让玩家选择2张，并登记破坏操作信息。
function c46833854.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c46833854.filter(chkc) end
	-- 发动时目标存在性检查：确认对方场上存在至少2张能够成为此效果对象的魔法·陷阱卡，否则无法发动。
	if chk==0 then return Duel.IsExistingTarget(c46833854.filter,tp,0,LOCATION_ONFIELD,2,nil) end
	-- 发送选择提示，提示文本为“请选择要破坏的卡”，供玩家从对方场上选择2张魔法·陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择2张魔法·陷阱卡作为效果对象，同时将其登记为当前连锁的对象卡。
	local g=Duel.SelectTarget(tp,c46833854.filter,tp,0,LOCATION_ONFIELD,2,2,nil)
	-- 设置操作信息：登记本次效果将破坏2张卡（目标为所选对象组g），用于连锁中其他效果（如无效破坏/替代破坏）的判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 效果处理：获取连锁中登记的对象卡，筛选出仍然与此效果相关的卡（未有离场或连锁重置），若还有剩余则将其全部破坏。
function c46833854.op(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理中记录的效果对象卡组，即发动时选择的那2张魔法·陷阱卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将筛选后仍关联的卡以效果破坏（REASON_EFFECT），送入墓地。
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
