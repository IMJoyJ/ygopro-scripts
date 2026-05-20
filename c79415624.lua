--蛇眼の断罪龍
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，以自己或对方的场上（表侧表示）·墓地1只怪兽为对象才能发动。那只怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。下个回合，这张卡不能使用这个效果。
-- ②：自己·对方的战斗阶段，以场上1只怪兽和场上1张永续魔法卡为对象才能发动。那些卡破坏。
local s,id,o=GetID()
-- 注册卡片的同调召唤手续、①效果（放置到魔陷区）和②效果（破坏效果）
function s.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己·对方的主要阶段，以自己或对方的场上（表侧表示）·墓地1只怪兽为对象才能发动。那只怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。下个回合，这张卡不能使用这个效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"放置到魔陷区"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCondition(s.mvcon)
	e1:SetTarget(s.mvtg)
	e1:SetOperation(s.mvop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的战斗阶段，以场上1只怪兽和场上1张永续魔法卡为对象才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：自己·对方的主要阶段，且本回合该卡没有被施加“下个回合不能使用”的标记
function s.mvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为主要阶段，且当前回合数不等于该卡记录的禁用回合数
	return Duel.IsMainPhase() and Duel.GetTurnCount()~=e:GetHandler():GetFlagEffectLabel(id)
end
-- 过滤满足“可以当作永续魔法卡放置到原本持有者魔陷区”的怪兽卡
function s.mvfilter(c,tp)
	local r=LOCATION_REASON_TOFIELD
	if not c:IsControler(c:GetOwner()) then
		if not c:IsAbleToChangeControler() then return false end
		r=LOCATION_REASON_CONTROL
	end
	return (c:IsLocation(LOCATION_MZONE) or c:IsType(TYPE_MONSTER) and not c:IsForbidden() and c:CheckUniqueOnField(c:GetOwner()))
		-- 判定卡片在场上时必须表侧表示（在墓地则无所谓），且原本持有者的魔陷区有空位
		and c:IsFaceupEx() and Duel.GetLocationCount(c:GetOwner(),LOCATION_SZONE,tp,r)>0
end
-- ①效果的靶向与合法性检测：选择场上或墓地的一只怪兽作为对象，若目标在墓地则设置离开墓地的操作信息
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and s.mvfilter(chkc,tp) end
	-- 判定是否存在可以作为①效果对象的场上（表侧表示）或墓地的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.mvfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 优先从场上（其次从墓地）选择1只满足条件的怪兽作为效果对象
	local g=aux.SelectTargetFromFieldFirst(tp,s.mvfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,1,nil,tp)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 若选择的对象在墓地，则设置“离开墓地”的操作信息
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- ①效果的执行：将对象怪兽移动到原本持有者的魔陷区，并使其当作永续魔法卡使用，同时为自身添加下回合不能使用该效果的标记
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判定对象怪兽是否仍存在且仍为怪兽，并进行王家之谷的过滤判定
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and aux.NecroValleyFilter()(tc)
		and not tc:IsImmuneToEffect(e)
		-- 将对象怪兽表侧表示移动到其原本持有者的魔法与陷阱区域
		and Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		-- 那只怪兽当作永续魔法卡使用
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 给自身注册一个持续2个回合的Flag，并记录下个回合的回合数，用于实现“下个回合，这张卡不能使用这个效果”
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2,Duel.GetTurnCount()+1)
	end
end
-- ②效果的发动条件：自己·对方的战斗阶段
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为战斗阶段
	return Duel.IsBattlePhase()
end
-- 过滤满足“是怪兽且场上存在另一张可破坏的永续魔法卡”的场上怪兽
function s.desfilter1(c,tp)
	-- 判定卡片是否为怪兽，且场上是否存在除其以外的表侧表示永续魔法卡
	return c:IsType(TYPE_MONSTER) and Duel.IsExistingTarget(s.desfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 过滤场上表侧表示的永续魔法卡
function s.desfilter2(c)
	return c:IsFaceup() and c:IsAllTypes(TYPE_CONTINUOUS|TYPE_SPELL)
end
-- ②效果的靶向与合法性检测：选择场上1只怪兽和场上1张永续魔法卡作为对象，并设置破坏的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判定场上是否存在可以作为破坏对象的怪兽和永续魔法卡
	if chk==0 then return Duel.IsExistingTarget(s.desfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的怪兽卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只怪兽作为破坏对象
	local g1=Duel.SelectTarget(tp,s.desfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 提示玩家选择要破坏的永续魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张永续魔法卡作为破坏对象
	local g2=Duel.SelectTarget(tp,s.desfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,g1)
	g1:Merge(g2)
	-- 设置破坏卡片的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
end
-- ②效果的执行：将选择的怪兽和永续魔法卡破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 因效果将这些卡破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
