--俱利伽羅天童
-- 效果：
-- 这张卡不能通常召唤。把这个回合有在对方的怪兽区域把效果发动过的自己·对方场上的表侧表示怪兽全部解放的场合才能特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升因为这张卡特殊召唤而解放的怪兽数量×1500。
-- ②：自己结束阶段，以对方墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，启用特殊召唤限制并注册3个效果：特殊召唤条件、特殊召唤规则、结束阶段效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把这个回合有在对方的怪兽区域把效果发动过的自己·对方场上的表侧表示怪兽全部解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.sprcon)
	e2:SetOperation(s.sprop)
	c:RegisterEffect(e2)
	-- 自己结束阶段，以对方墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		-- 注册连锁处理时的全局检查效果，用于记录对方怪兽区域发动效果的卡片
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(s.checkop)
		-- 将全局检查效果注册到游戏环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 处理连锁结束时的效果，标记发动过效果的卡片
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if not rc:IsRelateToEffect(re) or not re:IsActiveType(TYPE_MONSTER) then return end
	-- 获取当前连锁的发动玩家和发动位置
	local p,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	if loc==LOCATION_MZONE and rc:GetFlagEffect(id+o+p)==0 then
		rc:RegisterFlagEffect(id+o+p,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 过滤函数，返回指定玩家场上满足条件的表侧表示怪兽
function s.rfilter(c,p)
	return c:IsFaceup() and c:GetFlagEffect(id+o+p)>0
end
-- 判断特殊召唤条件是否满足：对方怪兽区域发动过效果的怪兽数量大于0且均可解放，并且场上怪兽区有足够空位
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取对方怪兽区域发动过效果的怪兽组
	local rg=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,1-tp)
	-- 判断是否受到凯撒斗技场影响
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_KAISER_COLOSSEUM) then
		-- 获取己方主要怪兽区的怪兽数量
		local t1=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
		-- 获取己方额外怪兽区的怪兽数量
		local t2=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		-- 获取己方主要怪兽区发动过效果的怪兽数量
		local r1=Duel.GetMatchingGroupCount(s.rfilter,tp,LOCATION_MZONE,0,nil,1-tp)
		-- 获取己方额外怪兽区发动过效果的怪兽数量
		local r2=Duel.GetMatchingGroupCount(s.rfilter,tp,0,LOCATION_MZONE,nil,1-tp)
		if t1-r1+1 > t2-r2 then return false end
	end
	-- 判断特殊召唤条件是否满足：对方怪兽区域发动过效果的怪兽数量大于0且均可解放，并且场上怪兽区有足够空位
	return rg:GetCount()>0 and rg:FilterCount(Card.IsReleasable,nil,REASON_SPSUMMON)==rg:GetCount() and aux.mzctcheck(rg,tp)
end
-- 处理特殊召唤操作，解放对方怪兽并增加攻击力
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取对方怪兽区域发动过效果的怪兽组
	local rg=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,1-tp)
	-- 以特殊召唤理由解放对方怪兽
	Duel.Release(rg,REASON_SPSUMMON)
	-- 为特殊召唤的卡片增加攻击力，数值为解放怪兽数量乘以1500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(rg:GetCount()*1500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 设置结束阶段效果的发动条件：当前回合玩家为效果持有者
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 过滤函数，判断卡片是否可以特殊召唤
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置结束阶段效果的目标选择逻辑
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.spfilter(chkc,e,tp) end
	-- 判断是否满足发动条件：己方场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件：对方墓地存在可特殊召唤的怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方墓地一只可特殊召唤的怪兽作为目标
	local g=Duel.SelectTarget(tp,s.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置效果操作信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理结束阶段效果的发动，将目标怪兽特殊召唤到己方场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到己方场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
