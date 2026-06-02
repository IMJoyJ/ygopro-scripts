--始まりの神ファーラ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把手卡的这张卡和手卡1张魔法·陷阱卡给对方观看才能发动。直到下个回合的结束时，双方不能对应给人观看的魔法·陷阱卡以及那些同名卡的效果的发动把效果发动。
-- ②：这张卡被魔法·陷阱卡的效果从手卡·场上送去墓地的场合才能发动。这张卡特殊召唤。
-- ③：这张卡从墓地特殊召唤的场合才能发动。得到对方场上1只攻击力最高的怪兽的控制权。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：把手卡的这张卡和手卡1张魔法·陷阱卡给对方观看才能发动。直到下个回合的结束时，双方不能对应给人观看的魔法·陷阱卡以及那些同名卡的效果的发动把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"出示"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.nccost)
	e1:SetOperation(s.ncop)
	c:RegisterEffect(e1)
	-- ②：这张卡被魔法·陷阱卡的效果从手卡·场上送去墓地的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡从墓地特殊召唤的场合才能发动。得到对方场上1只攻击力最高的怪兽的控制权。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"得到控制权"
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.ctcon)
	e3:SetTarget(s.cttg)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
end
-- 过滤手卡中表侧表示以外的魔法·陷阱卡
function s.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsPublic()
end
-- 出示此卡和手卡1张魔陷卡作为发动Cost的处理函数
function s.nccost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判定手卡中此卡是否未出示，且是否存在另一张可给对方确认的魔陷卡
	if chk==0 then return not c:IsPublic() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,c) end
	-- 给玩家发送选择确认卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡中选择1张未确认的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,c)
	local sc=g:GetFirst()
	g:AddCard(c)
	-- 给对方玩家确认所选择的手牌卡片组
	Duel.ConfirmCards(1-tp,g)
	-- 由于手牌信息改变，将发动玩家的手牌重新洗切
	Duel.ShuffleHand(tp)
	e:SetLabel(sc:GetCode())
end
-- 阻止双方对应给人观看魔陷及其同名卡的效果发动处理函数
function s.ncop(e,tp,eg,ep,ev,re,r,rp)
	-- 直到下个回合的结束时，双方不能对应给人观看的魔法·陷阱卡以及那些同名卡的效果的发动把效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetLabel(e:GetLabel())
	e1:SetOperation(s.actop)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 为玩家注册禁止对应特定卡片进行连锁的全局连锁限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 当连锁发动的卡片代码与展示的卡片代码一致时，限制后续链条的响应
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsCode(e:GetLabel()) then
		-- 设定双方玩家不能对应当前处理的效果把效果发动
		Duel.SetChainLimit(aux.FALSE)
	end
end
-- 判定这张卡是否被魔法·陷阱卡的效果从手卡或场上送去墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and c:IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end
-- 被魔陷效果送墓特殊召唤效果的靶子判定
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上的怪兽区域是否还有空位，且这张卡自身是否能特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息为将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 被魔陷效果送墓时将自身特殊召唤的实际处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定这张卡是否仍与连锁关联且不受王家长眠之谷限制的影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判定这张卡特殊召唤前的位置是否是自己墓地
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 过滤对方场上表侧表示、可改变控制权、且攻击力是对方场上最高的怪兽
function s.tgfilter(c,tp)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
		-- 判定对方场上是否存在攻击力不高于目标怪兽的其他怪兽，以确认目标怪兽是攻击力最高
		and not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsAttackAbove),tp,0,LOCATION_MZONE,1,nil,c:GetAttack()+1)
end
-- 得到对方场上1只攻击力最高怪兽的控制权效果的靶子判定
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在可夺取控制权的攻击力最高怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 设置连锁操作信息为获取怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
-- 夺取对方场上最高攻击力怪兽控制权的实际处理
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示且攻击力最高的怪兽组
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,0,LOCATION_MZONE,nil,tp)
	if g:GetCount()==0 then return end
	local tc=g:GetFirst()
	if g:GetCount()>1 then
		-- 给玩家发送选择控制权改变目标怪兽的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		tc=g:Select(tp,1,1,nil):GetFirst()
	end
	if tc then
		-- 显示选定怪兽为连锁目标的动画效果
		Duel.HintSelection(Group.FromCards(tc))
		-- 让发动玩家获取目标怪兽的控制权
		Duel.GetControl(tc,tp)
	end
end
