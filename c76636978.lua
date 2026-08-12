--スターダスト・ドラゴン－ヴィクテム・サンクチュアリ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次，同一连锁上不能发动。
-- ①：对方连锁自己的效果的发动把魔法·陷阱·怪兽的效果发动时，把这张卡解放才能发动。那个对方的效果的发动无效并破坏。
-- ②：自己怪兽被解放的自己·对方回合，把墓地的这张卡除外才能发动。从额外卡组把1只「星尘」同调怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果：设置同调召唤手续，注册发动的无效与破坏效果、墓地特殊召唤效果，以及全局解放检测效果。
function s.initial_effect(c)
	-- 设置同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：对方连锁自己的效果的发动把魔法·陷阱·怪兽的效果发动时，把这张卡解放才能发动。那个对方的效果的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动无效"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	-- ②：自己怪兽被解放的自己·对方回合，把墓地的这张卡除外才能发动。从额外卡组把1只「星尘」同调怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.sscon)
	-- 效果发动代价：把墓地的这张卡除外才能发动
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sstg)
	e2:SetOperation(s.ssop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 这个卡名的①②的效果1回合各能使用1次，同一连锁上不能发动。①：对方连锁自己的效果的发动把魔法·陷阱·怪兽的效果发动时，把这张卡解放才能发动。那个对方的效果的发动无效并破坏。②：自己怪兽被解放的自己·对方回合，把墓地的这张卡除外才能发动。从额外卡组把1只「星尘」同调怪兽特殊召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_RELEASE)
		ge1:SetOperation(s.checkop)
		-- 将全局效果注册给0号玩家（对双方玩家生效）
		Duel.RegisterEffect(ge1,0)
	end
end
-- ①效果的发动条件判定函数
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前连锁无法被无效，则返回false
	if not Duel.IsChainDisablable(ev) then return false end
	-- 获取上一个连锁效果和触发玩家
	local te,p=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return te and p==tp and rp==1-tp
end
-- 过滤墓地中可以代替解放除外的卡片
function s.excostfilter(c,tp)
	return c:IsAbleToRemoveAsCost() and c:IsHasEffect(84012625,tp)
end
-- ①效果的Cost发动代价处理函数
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Group.CreateGroup()
	local c=e:GetHandler()
	if c:IsReleasable() then g:AddCard(c) end
	-- 如果是「星尘」卡片，合并墓地中可用于代替解放的卡片
	if c:IsSetCard(0xa3) then g:Merge(Duel.GetMatchingGroup(s.excostfilter,tp,LOCATION_GRAVE,0,nil,tp)) end
	if chk==0 then return #g>0 end
	local tc
	if #g>1 then
		-- 给玩家发送提示信息：选择要解放或代替解放除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(84012625,0))  --"请选择要解放或代替解放除外的卡"
		tc=g:Select(tp,1,1,nil):GetFirst()
	else
		tc=g:GetFirst()
	end
	local te=tc:IsHasEffect(84012625,tp)
	if te then
		-- 如果是代替解放的卡片，则将其表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_COST+REASON_REPLACE)
	else
		-- 如果不是代替解放，则将所选卡片解放
		Duel.Release(tc,REASON_COST)
	end
end
-- ①效果的Target目标处理函数
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定该效果在当前连锁中是否未发动过（同一连锁上不能发动）
	if chk==0 then return Duel.GetFlagEffect(tp,id+o)==0 end
	-- 设置当前处理的连锁信息：包含效果发动无效的操作
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若对应触发效果的卡片可破坏且与效果相关，设置其破坏的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	-- 在当前连锁中注册已发动标识（用于限制同一连锁不能发动）
	Duel.RegisterFlagEffect(tp,id+o,RESET_CHAIN,0,1)
end
-- ①效果的Operation具体操作处理函数
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功无效了连锁的发动，且该卡片与连锁相关
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 破坏被无效连锁发动的卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 过滤在场上被解放的怪兽
function s.chkfilter(c,p)
	return c:GetPreviousControler()==p and (c:IsPreviousLocation(LOCATION_MZONE) or c:IsType(TYPE_MONSTER))
end
-- 全局解放检测效果的Operation函数，当有怪兽被解放时，为对应玩家注册标识效果
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		if eg:IsExists(s.chkfilter,1,nil,p) then
			-- 为控制者注册当回合结束前有效的Flag效果，标识本回合有怪兽被解放
			Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
-- ②效果的发动条件判定函数
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查本回合自己是否有怪兽被解放的Flag标记
	return Duel.GetFlagEffect(tp,id)>0
end
-- 过滤额外卡组中的「星尘」同调怪兽
function s.ssfilter(c,e,tp)
	return c:IsSetCard(0xa3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsType(TYPE_SYNCHRO)
		-- 检查以该玩家来看的额外怪兽区域是否有可用的空位
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②效果的Target目标处理函数
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在可以特殊召唤的符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		-- 检查并在连锁中注册发动标识（用于限制同一连锁不能发动）
		and Duel.GetFlagEffect(tp,id+o)==0 end
	-- 设置从额外卡组特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 在当前连锁中注册已发动标识（用于限制同一连锁不能发动）
	Duel.RegisterFlagEffect(tp,id+o,RESET_CHAIN,0,1)
end
-- ②效果的Operation具体操作处理函数
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择1只符合条件的「星尘」同调怪兽
	local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的同调怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
