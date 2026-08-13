--魔轟神ディアネイラ
-- 效果：
-- 这张卡可以把1只「魔轰神」怪兽解放表侧攻击表示上级召唤。
-- ①：只要这张卡在怪兽区域存在，对方把通常魔法卡发动的场合，1回合只有1次让那个效果变成「对方选1张手卡丢弃」。
function c53199020.initial_effect(c)
	-- 这张卡可以把1只「魔轰神」怪兽解放表侧攻击表示上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53199020,0))  --"把1只名字带有「魔轰神」的怪兽解放召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c53199020.otcon)
	e1:SetOperation(c53199020.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，对方把通常魔法卡发动的场合，1回合只有1次让那个效果变成「对方选1张手卡丢弃」。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c53199020.chcon1)
	e2:SetOperation(c53199020.chop1)
	c:RegisterEffect(e2)
	-- 让那个效果变成「对方选1张手卡丢弃」。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c53199020.chcon2)
	e3:SetOperation(c53199020.chop2)
	c:RegisterEffect(e3)
end
-- 筛选可作为解放素材的「魔轰神」怪兽：必须是「魔轰神」字段，且是自己控制或表侧表示（允许选择对方场上表侧的魔轰神）。
function c53199020.otfilter(c,tp)
	return c:IsSetCard(0x35) and (c:IsControler(tp) or c:IsFaceup())
end
-- 上级召唤的召唤条件：此卡等级为7以上，解放数量要求为1只，且场上存在可用的「魔轰神」祭品。
function c53199020.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 从双方场上获取满足条件的「魔轰神」怪兽群（自己控制或对方表侧表示），作为候选祭品。
	local mg=Duel.GetMatchingGroup(c53199020.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判定召唤是否可行：这张卡等级不低于7，所需祭品数不超过1，且通过Duel.CheckTribute确认场上存在符合的祭品。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤的处理操作：从候选祭品中选择1只「魔轰神」怪兽，设定为召唤素材并解放，完成表侧攻击表示的上级召唤。
function c53199020.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 在执行召唤时重新获取双方场上可用的「魔轰神」怪兽群，用于让玩家选择解放素材。
	local mg=Duel.GetMatchingGroup(c53199020.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家选择1只「魔轰神」怪兽作为这次上级召唤的解放素材。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选中的祭品，解放原因记为召唤和作为上级召唤素材。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 触发条件：对方发动通常魔法卡（ep为对方，卡类型为通常魔法且作为魔法卡发动）。
function c53199020.chcon1(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:GetHandler():GetType()==TYPE_SPELL and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 给这张通常魔法卡注册一个53199020编号的标记，重置时机为连锁结束，数量1，用于在解决阶段识别该卡。
function c53199020.chop1(e,tp,eg,ep,ev,re,r,rp)
	re:GetHandler():RegisterFlagEffect(53199020,RESET_CHAIN,0,1)
end
-- 触发条件：当前连锁中解决的效果正是刚才被标记过的对方通常魔法卡效果。
function c53199020.chcon2(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():GetFlagEffect(53199020)>0
end
-- 效果解决时的处理：将原效果的对象改为空，并把连锁处理函数替换为让对手丢弃手卡的效果。
function c53199020.chop2(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 把该连锁当前选择的对象卡改为空组，即取消原通常魔法可能拥有的取对象。
	Duel.ChangeTargetCard(ev,g)
	-- 将连锁的效果处理函数替换为c53199020.rep_op，从而让该通常魔法的效果变为「对方选1张手卡丢弃」。
	Duel.ChangeChainOperation(ev,c53199020.rep_op)
end
-- 替换后的效果处理：展示此卡，并令对方玩家丢弃1张手卡。
function c53199020.rep_op(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方提示卡号53199020，显示狄阿尼拉的效果发动动画/提示。
	Duel.Hint(HINT_CARD,0,53199020)
	-- 让对方玩家从手卡选出1张卡丢弃，丢弃原因包括效果和丢弃。
	Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
end
