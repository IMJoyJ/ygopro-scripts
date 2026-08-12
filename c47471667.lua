--D－バースト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1张表侧表示的魔法卡为对象才能发动。那张卡破坏，自己抽1张。那之后，自己场上有「命运英雄」怪兽存在的场合，可以把自己的手卡·墓地·除外状态的1只「命运英雄」怪兽特殊召唤。
-- ②：有装备卡装备的怪兽或者「命运英雄 教义人」攻击的伤害步骤结束时，把墓地的这张卡除外才能发动。那只攻击怪兽只再1次可以继续攻击。
local s,id,o=GetID()
-- 初始化这张卡的全部效果：注册卡名记载与系列字段，创建并注册效果①（破坏·抽卡·特殊召唤的魔法卡发动效果）和效果②（墓地的再次攻击诱发效果）
function s.initial_effect(c)
	-- 记录这张卡上记载着卡名「命运英雄 教义人」（卡号17132130）
	aux.AddCodeList(c,17132130)
	-- 向这张卡注册「命运英雄」系列字段（0xc008），用于效果文本中「命运英雄」怪兽的判定
	aux.AddSetNameMonsterList(c,0xc008)
	-- ①：以自己场上1张表侧表示的魔法卡为对象才能发动。那张卡破坏，自己抽1张。那之后，自己场上有「命运英雄」怪兽存在的场合，可以把自己的手卡·墓地·除外状态的1只「命运英雄」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：有装备卡装备的怪兽或者「命运英雄 教义人」攻击的伤害步骤结束时，把墓地的这张卡除外才能发动。那只攻击怪兽只再1次可以继续攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"再次攻击"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.atkcon)
	-- 设置发动代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 定义破坏对象的过滤条件：表侧表示的魔法卡
function s.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
-- 对象合法性检查：连锁对象必须是自己场上表侧表示的魔法卡且不是这张卡本身
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp)
		and s.desfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查自己是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查自己场上是否存在可以成为对象的表侧表示魔法卡（这张卡本身除外）
		and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择自己场上1张表侧表示的魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 把当前连锁的对象玩家设置为自己（用于后续抽卡的玩家）
	Duel.SetTargetPlayer(tp)
	-- 把当前连锁的对象参数设置为1（用于后续抽卡的张数）
	Duel.SetTargetParam(1)
	-- 设置操作信息：确定要破坏对象卡1张
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：确定自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义过滤条件：自己场上表侧表示的「命运英雄」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc008)
end
-- 定义特殊召唤候选的过滤条件：表侧状态（含除外状态的表侧）的「命运英雄」怪兽且可以被特殊召唤
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0xc008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的处理：破坏对象卡，自己抽1张，之后若自己场上有「命运英雄」怪兽且满足条件，则询问玩家是否从手卡·墓地·除外状态特殊召唤1只「命运英雄」怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象玩家和对象参数（即抽卡的玩家和张数）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 取得与当前连锁关联的对象卡片组（被选择为对象的魔法卡）
	local dg=Duel.GetTargetsRelateToChain()
	-- 若对象卡存在则将其破坏，且破坏成功才继续后续处理
	if dg:GetCount()>0 and Duel.Destroy(dg,REASON_EFFECT)>0
		-- 自己抽1张卡，且抽卡成功才继续后续处理
		and Duel.Draw(p,d,REASON_EFFECT)~=0
		-- 检查自己怪兽区域是否存在表侧表示的「命运英雄」怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己的主要怪兽区域是否有可用空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡·墓地·除外状态是否存在可以特殊召唤的「命运英雄」怪兽（不受王家长眠之谷影响）
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
		-- 询问玩家是否进行特殊召唤，选择是才继续
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从自己的手卡·墓地·除外状态选择1只可以特殊召唤的「命运英雄」怪兽
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			-- 中断当前效果，使特殊召唤与前面的破坏·抽卡视为不同时处理
			Duel.BreakEffect()
			-- 把选择的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 效果②的发动条件：此次战斗的攻击怪兽有装备卡装备或者是「命运英雄 教义人」，且可以继续攻击
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得此次战斗进行攻击的怪兽
	local at=Duel.GetAttacker()
	return (at:GetEquipCount()>0 or at:IsCode(17132130)) and at:IsChainAttackable()
end
-- 效果②的对象检查：无额外条件，始终可以发动
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 效果②的处理：使那只攻击怪兽只再1次可以继续攻击
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 使攻击怪兽可以再攻击1次
	Duel.ChainAttack()
end
