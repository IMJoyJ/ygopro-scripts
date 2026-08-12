--蕾禍大輪首狩舞
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以最多有自己场上的昆虫族·植物族·爬虫类族连接怪兽的种族种类数量的对方场上的卡为对象才能发动。那些卡破坏。
-- ②：这个回合没有送去墓地的这张卡在墓地存在的状态，自己场上的表侧表示的昆虫族·植物族·爬虫类族怪兽被战斗·效果破坏的场合，把这张卡除外，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（场上发动破坏对方卡片）和②效果（墓地诱发破坏对方怪兽）
function s.initial_effect(c)
	-- ①：以最多有自己场上的昆虫族·植物族·爬虫类族连接怪兽的种族种类数量的对方场上的卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：这个回合没有送去墓地的这张卡在墓地存在的状态，自己场上的表侧表示的昆虫族·植物族·爬虫类族怪兽被战斗·效果破坏的场合，把这张卡除外，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon2)
	-- 设置发动代价为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.destg2)
	e2:SetOperation(s.desop2)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的昆虫族、植物族或爬虫类族连接怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE) and c:IsType(TYPE_LINK)
end
-- ①效果的发动准备与目标选择函数
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查自己场上是否存在至少1只满足条件的昆虫族/植物族/爬虫类族连接怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且对方场上存在至少1张可以作为对象的目标卡片
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取自己场上所有满足条件的昆虫族/植物族/爬虫类族连接怪兽
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	local gc=g:GetClassCount(Card.GetRace)
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择最多等同于上述怪兽种族种类数量的对方场上的卡作为效果对象
	local sg=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,gc,nil)
	-- 设置连锁信息，表明此效果的操作为破坏选定的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- ①效果的处理函数，破坏作为对象的卡片
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 因效果破坏这些卡片
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- 过滤条件：原本在自己场上表侧表示存在的昆虫族、植物族或爬虫类族怪兽因战斗或效果被破坏
function s.cfilter2(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and bit.band(c:GetPreviousRaceOnField(),RACE_INSECT+RACE_PLANT+RACE_REPTILE)~=0
		and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- ②效果的发动条件判断函数
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	-- 确认这张卡不是本回合送去墓地，且自己场上满足条件的怪兽被破坏，同时被破坏的卡中不包含这张卡自身
	return aux.exccon(e) and eg:IsExists(s.cfilter2,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- ②效果的发动准备与目标选择函数
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少1只可以作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表明此效果的操作为破坏选定的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果的处理函数，破坏作为对象的怪兽
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏该怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
