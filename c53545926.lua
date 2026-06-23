--共闘闘君
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把自己场上的衍生物任意数量解放，以自己场上1只攻击力0的怪兽为对象才能发动。那只怪兽直到回合结束时攻击力上升解放数量×1000，同1次的战斗阶段中可以向怪兽作出最多有解放数量的攻击。
-- ②：对方战斗阶段结束时才能发动。把最多有这次战斗阶段中被破坏的衍生物数量的「共斗衍生物」（兽族·地·1星·攻/守0）在自己场上特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的发动效果、①效果和②效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：把自己场上的衍生物任意数量解放，以自己场上1只攻击力0的怪兽为对象才能发动。那只怪兽直到回合结束时攻击力上升解放数量×1000，同1次的战斗阶段中可以向怪兽作出最多有解放数量的攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.atkcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	-- ②：对方战斗阶段结束时才能发动。把最多有这次战斗阶段中被破坏的衍生物数量的「共斗衍生物」（兽族·地·1星·攻/守0）在自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"请选择要特殊召唤的衍生物的数量"
	e3:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.tkcon)
	e3:SetTarget(s.tktg)
	e3:SetOperation(s.tkop)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		-- 注册全局持续效果，用于记录战斗阶段中被破坏的衍生物数量
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.checkop)
		-- 将全局持续效果注册到游戏环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 检查当前阶段是否为战斗阶段，若为则记录被破坏的衍生物
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为战斗阶段开始到战斗阶段结束之间
	if Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE then
		-- 遍历被破坏的卡片组，检查是否为衍生物
		for tc in aux.Next(eg) do
			if tc:IsType(TYPE_TOKEN) then
				-- 为玩家0注册一个标识效果，用于记录战斗阶段中被破坏的衍生物数量
				Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_BATTLE,0,1)
			end
		end
	end
end
-- ①效果的解放费用处理函数，设置标签为100表示已支付费用
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 筛选函数，用于判断场上是否存在可作为解放对象的衍生物
function s.costfilter(c,tp)
	-- 判断卡片是否为衍生物且场上存在攻击力为0的表侧表示怪兽
	return c:IsType(TYPE_TOKEN) and Duel.IsExistingTarget(s.matfilter1,tp,LOCATION_MZONE,0,1,c)
end
-- 筛选函数，用于判断场上是否存在攻击力为0的表侧表示怪兽
function s.matfilter1(c)
	return c:IsFaceup() and c:IsAttack(0)
end
-- 筛选函数，用于判断所选衍生物组是否满足解放条件并能选择目标怪兽
function s.fselect(g,tp)
	-- 判断所选衍生物组是否能选择到攻击力为0的表侧表示怪兽
	return Duel.IsExistingTarget(s.matfilter1,tp,LOCATION_MZONE,0,1,g)
		-- 判断所选衍生物组是否满足解放条件
		and Duel.CheckReleaseGroup(tp,aux.IsInGroup,#g,nil,g)
end
-- ①效果的发动处理函数，选择解放衍生物并选择目标怪兽
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.matfilter1(chkc) end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		-- 检查场上是否存在满足条件的衍生物可作为解放对象
		return Duel.CheckReleaseGroup(tp,s.costfilter,1,nil,tp)
	end
	-- 获取玩家可解放的衍生物组
	local rg=Duel.GetReleaseGroup(tp):Filter(s.costfilter,nil,tp)
	-- 提示玩家选择要解放的衍生物
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,s.fselect,false,1,rg:GetCount(),tp)
	-- 使用额外解放次数处理函数，处理可能的代替解放
	aux.UseExtraReleaseCount(sg,tp)
	-- 实际进行衍生物的解放操作
	local ct=Duel.Release(sg,REASON_COST)
	e:SetLabel(ct)
	-- 提示玩家选择表侧表示的攻击力为0的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,s.matfilter1,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①效果的发动后处理函数，为选中的怪兽增加攻击力并设置额外攻击次数
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 为选中的怪兽增加攻击力，数值为解放衍生物数量×1000
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel()*1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		if not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) and e:GetLabel()>1 then
			-- 若解放数量大于1，则为选中的怪兽增加额外攻击次数
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e2:SetRange(LOCATION_MZONE)
			e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
			e2:SetValue(e:GetLabel()-1)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end
-- ②效果的发动条件函数，判断是否为对方的战斗阶段结束
function s.tkcon(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断当前回合玩家是否为对方玩家
	return Duel.GetTurnPlayer()==1-tp
end
-- ②效果的发动处理函数，判断是否可以发动并设置操作信息
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动②效果的条件
	if chk==0 then return Duel.GetFlagEffect(0,id)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():GetFlagEffect(id)==0
		-- 判断玩家是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH) end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	-- 设置操作信息，表示将特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息，表示将特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ②效果的发动后处理函数，根据被破坏的衍生物数量特殊召唤衍生物
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取战斗阶段中被破坏的衍生物数量
	local ct=Duel.GetFlagEffect(0,id)
	-- 判断是否满足发动②效果的条件
	if ft>0 and ct>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH) then
		local count=math.min(ft,ct)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then count=1 end
		if count>1 then
			local num={}
			local i=1
			while i<=count do
				num[i]=i
				i=i+1
			end
			-- 提示玩家选择要特殊召唤的衍生物数量
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))  --"请选择要特殊召唤的衍生物的数量"
			-- 玩家选择要特殊召唤的衍生物数量
			count=Duel.AnnounceNumber(tp,table.unpack(num))
		end
		repeat
			-- 创建一个衍生物
			local token=Duel.CreateToken(tp,id+o)
			-- 特殊召唤一个衍生物
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			count=count-1
		until count==0
		-- 完成特殊召唤操作
		Duel.SpecialSummonComplete()
	end
end
