--共闘闘君
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把自己场上的衍生物任意数量解放，以自己场上1只攻击力0的怪兽为对象才能发动。那只怪兽直到回合结束时攻击力上升解放数量×1000，同1次的战斗阶段中可以向怪兽作出最多有解放数量的攻击。
-- ②：对方战斗阶段结束时才能发动。把最多有这次战斗阶段中被破坏的衍生物数量的「共斗衍生物」（兽族·地·1星·攻/守0）在自己场上特殊召唤。
local s,id,o=GetID()
-- 初始化效果注册：e1为魔陷发动用空效果；e2为①起动效果（解放任意数量衍生物，选择自己场上1只攻击力0怪兽，上升攻击力并追加攻击次数）；e3为②诱发效果（对方战斗阶段结束时特殊召唤共斗衍生物）；并注册全局效果监听战斗阶段中衍生物被破坏的数量。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：把自己场上的衍生物任意数量解放，以自己场上1只攻击力0的怪兽为对象才能发动。那只怪兽直到回合结束时攻击力上升解放数量×1000，同1次的战斗阶段中可以向怪兽作出最多有解放数量的攻击。
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
		-- ①：把自己场上的衍生物任意数量解放，以自己场上1只攻击力0的怪兽为对象才能发动。那只怪兽直到回合结束时攻击力上升解放数量×1000，同1次的战斗阶段中可以向怪兽作出最多有解放数量的攻击。②：对方战斗阶段结束时才能发动。把最多有这次战斗阶段中被破坏的衍生物数量的「共斗衍生物」（兽族·地·1星·攻/守0）在自己场上特殊召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.checkop)
		-- 将监测场上衍生物被破坏的全局效果ge1注册到全字段，用于累计本战斗阶段被破坏的衍生物数量。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 当任意卡片被破坏时，若处于战斗阶段且被破坏的是衍生物，则为玩家0累计1次破坏计数，供②效果使用。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为战斗阶段（战斗阶段开始到战斗阶段结束之间），只在战斗阶段内记录衍生物破坏。
	if Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE then
		-- 遍历本次被破坏的卡片集合eg，逐一确认是否有衍生物。
		for tc in aux.Next(eg) do
			if tc:IsType(TYPE_TOKEN) then
				-- 为玩家0登记一个标识（战斗阶段结束时重置），表示本战斗阶段有1只衍生物被破坏；该标识数量即被破坏的衍生物数量。
				Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_BATTLE,0,1)
			end
		end
	end
end
-- 定义①效果的代价函数：由于实际解放数量和对象选择需在发动时确定，这里仅设置标签100作为已通过代价检查的标记，并返回true使发动进入目标选择阶段。
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 定义解放候选过滤：候选卡必须是衍生物，且场上存在除该候选外可作为对象的表侧攻击力0怪兽。
function s.costfilter(c,tp)
	-- 判断候选卡是衍生物，并且场上存在其他满足条件的攻击力0表侧怪兽作为效果对象。
	return c:IsType(TYPE_TOKEN) and Duel.IsExistingTarget(s.matfilter1,tp,LOCATION_MZONE,0,1,c)
end
-- 定义效果对象过滤：表侧表示且攻击力为0的自己怪兽。
function s.matfilter1(c)
	return c:IsFaceup() and c:IsAttack(0)
end
-- 校验玩家选择的解放衍生物组：需要存在攻击力0怪兽可作为对象，且该组衍生物全部可合法解放。
function s.fselect(g,tp)
	-- 检查在玩家怪兽区是否存在1只表侧攻击力0的怪兽可作为效果对象。
	return Duel.IsExistingTarget(s.matfilter1,tp,LOCATION_MZONE,0,1,g)
		-- 检查所选解放组中的所有衍生物都能作为解放代价被解放。
		and Duel.CheckReleaseGroup(tp,aux.IsInGroup,#g,nil,g)
end
-- 定义①效果的目标处理函数：判定发动合法，选择解放的衍生物组，执行解放，再选择攻击力0的对象怪兽，并将解放数量记录到效果标签中。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.matfilter1(chkc) end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		-- 检查玩家场上是否至少有1张可解放的衍生物且满足选对象条件，以此作为①效果发动的合法性条件。
		return Duel.CheckReleaseGroup(tp,s.costfilter,1,nil,tp)
	end
	-- 获取玩家所有可解放的卡并筛选出可作为解放代价的衍生物组（同时需保证场上有攻击力0对象）。
	local rg=Duel.GetReleaseGroup(tp):Filter(s.costfilter,nil,tp)
	-- 向玩家显示‘请选择要解放的卡’的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,s.fselect,false,1,rg:GetCount(),tp)
	-- 处理代替解放等额外解放次数效果，使这组衍生物能正确作为解放代价被消耗。
	aux.UseExtraReleaseCount(sg,tp)
	-- 将选中的衍生物组作为①效果的cost解放，返回实际解放数量并存入效果标签，用于后续提升攻击力和追加攻击次数。
	local ct=Duel.Release(sg,REASON_COST)
	e:SetLabel(ct)
	-- 向玩家显示‘请选择表侧表示的卡’的选对象提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示且攻击力0的怪兽作为①效果处理时的对象。
	Duel.SelectTarget(tp,s.matfilter1,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 定义①效果处理函数：让对象怪兽攻击力上升解放数量×1000；若解放数量>1且对象没有‘攻击力反转变化’效果，则再赋予其本回合可追加攻击的次数（解放数量-1次）。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽直到回合结束时攻击力上升解放数量×1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel()*1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		if not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) and e:GetLabel()>1 then
			-- 同1次的战斗阶段中可以向怪兽作出最多有解放数量的攻击。
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
-- 定义②效果的发动条件：必须是对方战斗阶段结束时（当前回合玩家不是自己）且在场上满足条件才能发动。
function s.tkcon(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断当前回合玩家是否为对手（1-tp），即只有对方回合才满足②的发动时机。
	return Duel.GetTurnPlayer()==1-tp
end
-- 定义②效果的发动目标函数：确认本战斗阶段有衍生物被破坏、自己怪兽区有空位、本卡尚未发动过②，且玩家可以特殊召唤共斗衍生物，满足则允许发动。
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性判定：已记录到本战斗阶段有衍生物被破坏，自己怪兽区有空位，并且这张卡在本次战斗阶段未发动过②效果。
	if chk==0 then return Duel.GetFlagEffect(0,id)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():GetFlagEffect(id)==0
		-- 同时确认玩家自身能够特殊召唤‘共斗衍生物’（兽族·地·1星·攻/守0）token。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH) end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	-- 设置本次连锁的操作信息：包含生成token，预计数量1个，用于时点检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置本次连锁的操作信息：包含特殊召唤，预计数量1只，用于时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 定义②效果处理函数：以可用的怪兽区空格数和本战斗阶段被破坏的衍生物数量中较小者为上限；若场上存在青眼精灵龙（禁止同时特殊召唤2只以上怪兽）则上限降为1；若上限>1则让玩家宣言要召唤的数量，然后按该数量逐个特殊召唤‘共斗衍生物’。
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上怪兽区的可用空格数，作为可特殊召唤token的数量上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取本战斗阶段被破坏的衍生物数量（由全局效果累计的flag数量），作为可以特殊召唤的token数量上限之一。
	local ct=Duel.GetFlagEffect(0,id)
	-- 确认怪兽区有空格、有被破坏的衍生物计数，并且玩家有特殊召唤共斗衍生物的能力，才执行特殊召唤流程。
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
			-- 向玩家显示‘请选择要特殊召唤的衍生物的数量’的选数提示。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))  --"请选择要特殊召唤的衍生物的数量"
			-- 让玩家从1到上限之间宣言一个数字，作为实际要特殊召唤的共斗衍生物数量。
			count=Duel.AnnounceNumber(tp,table.unpack(num))
		end
		repeat
			-- 创建1只卡号为id+o的‘共斗衍生物’token。
			local token=Duel.CreateToken(tp,id+o)
			-- 将刚创建的token作为特殊召唤的一步，以表侧攻击表示特殊召唤到自己场上，不检查召唤条件和苏生限制。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			count=count-1
		until count==0
		-- 完成所有token的特殊召唤步骤，统一触发特殊召唤成功的时点。
		Duel.SpecialSummonComplete()
	end
end
