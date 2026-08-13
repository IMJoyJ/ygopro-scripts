--スターシップ・アジャスト・プレーン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：以自己场上1只其他的机械族怪兽为对象才能发动。那只怪兽和这张卡的等级直到回合结束时变成那2只的等级合计的等级。这个效果的发动后，直到回合结束时自己不是机械族超量怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 定义卡片的初始效果：创建一个起动效果并注册给卡片，实现①的发动条件、取对象、等级变更处理和发动后的额外特殊召唤自肃。
function s.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：以自己场上1只其他的机械族怪兽为对象才能发动。那只怪兽和这张卡的等级直到回合结束时变成那2只的等级合计的等级。这个效果的发动后，直到回合结束时自己不是机械族超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"等级变化"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
end
-- 定义对象筛选条件：对象必须是表侧表示、等级1以上、机械族的怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsRace(RACE_MACHINE)
end
-- 目标选择处理：先做连锁对象合法性检查，再在己方怪兽区域检索满足条件且不是本卡的机械族怪兽，并让玩家选择1只作为效果对象。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc) and chkc~=c end
	-- 发动条件判定：本卡自身等级在1以上，并且己方怪兽区域存在除自身以外的1只满足筛选条件的机械族怪兽时，效果才能发动。
	if chk==0 then return c:IsLevelAbove(1) and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,c) end
	-- 向玩家显示“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从己方怪兽区域选择1只满足筛选条件且不是本卡自身的机械族怪兽，并将其设为效果对象。
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,c)
end
-- 效果处理：先确认本卡和对象怪兽仍与连锁相关且表侧存在于怪兽区域；若满足，则计算两怪当前等级合计，给本卡和对象各赋予一个不可无效的等级变更效果，使等级变成该合计并持续到结束阶段；随后无条件给自己附加本回合的额外卡组特殊召唤自肃。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and c:IsFaceup() and c:IsType(TYPE_MONSTER)
		and tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		local lv=c:GetLevel()+tc:GetLevel()
		-- 那只怪兽和这张卡的等级直到回合结束时变成那2只的等级合计的等级。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		tc:RegisterEffect(e2)
	end
	-- 这个效果的发动后，直到回合结束时自己不是机械族超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把该自肃效果作为影响玩家的场地效果注册到场上，对发动玩家tp生效，持续到回合结束时。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃的判定条件：从额外卡组特殊召唤的怪兽，若不是机械族超量怪兽，则不能进行特殊召唤。
function s.splimit(e,c)
	return not (c:IsRace(RACE_MACHINE) and c:IsType(TYPE_XYZ)) and c:IsLocation(LOCATION_EXTRA)
end
