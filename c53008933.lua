--デーモンの光来
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上有「光之黄金柜」存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡召唤·特殊召唤的场合，以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。这个效果的发动时自己场上没有「光之黄金柜」存在的场合，这个效果得到控制权的怪兽不能攻击。
-- ③：自己场上的其他怪兽的攻击力在自己回合内上升500。
local s,id,o=GetID()
-- 初始化并注册这张卡的全部效果：①满足自己场上有「光之黄金柜」时可不解放作召唤；②召唤·特殊召唤成功时取对方怪兽获得控制权直到结束阶段，且无「光之黄金柜」时该怪兽不能攻击；③自己回合自己场上的其他怪兽攻击力上升500。
function s.initial_effect(c)
	-- 将卡号79791878（光之黄金柜）登记为本卡的卡名记述，使本卡能被「光之黄金柜」的检索效果等判定为“有「光之黄金柜」的卡名记述”的卡。
	aux.AddCodeList(c,79791878)
	-- ①：自己场上有「光之黄金柜」存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"不用解放作召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡召唤·特殊召唤的场合，以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。这个效果的发动时自己场上没有「光之黄金柜」存在的场合，这个效果得到控制权的怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"得到控制权"
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：自己场上的其他怪兽的攻击力在自己回合内上升500。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(s.atkcon)
	e4:SetTarget(s.atktg)
	e4:SetValue(500)
	c:RegisterEffect(e4)
end
-- 过滤出表侧表示的「光之黄金柜」（卡号79791878），用于判断自己场上是否存在符合条件的「光之黄金柜」。
function s.ntfilter(c)
	return c:IsFaceup() and c:IsCode(79791878)
end
-- 「不用解放作召唤」的召唤手续条件判定：当c为空时视为该召唤手续适用；否则要求最低解放数为0、这张卡为5星以上、召唤者主要怪兽区有空位，且自己场上存在表侧表示的「光之黄金柜」。
function s.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判定最低解放数为0且这张卡等级在5星以上，同时召唤者的主要怪兽区存在可用空格。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 确认自己场上（怪兽区与魔法与陷阱区）存在1张表侧表示的「光之黄金柜」，满足①效果的前置条件。
		and Duel.IsExistingMatchingCard(s.ntfilter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end
-- ②效果的发动条件和对象选择：检查对方场上是否存在控制权可变更的怪兽；若有则让玩家选择其中1只作为对象，设置操作信息为改变控制权；同时记录自己场上是否有「光之黄金柜」，用label标记（1有/0无），供处理时决定是否附加不能攻击限制。
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 发动合法性检查：确认存在至少1只对方场上、控制权可以变更的怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择提示信息：请选择要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 执行对象选择：从对方场上选择1只控制权可变更的怪兽，并登记为这张卡效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息为改变控制权，对象为所选怪兽，数量为1，供其他效果（如星尘龙等）检测。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	-- 检查自己场上是否存在表侧表示的「光之黄金柜」，以确定获得控制权的怪兽是否需要在结束阶段前被附加不能攻击的限制；存在则label为1，不存在则label为0。
	if Duel.IsExistingMatchingCard(s.ntfilter,tp,LOCATION_ONFIELD,0,1,nil) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
-- ②效果处理：获得对象怪兽的控制权直到结束阶段；若发动时自己场上没有「光之黄金柜」（label≠1），则给该怪兽赋予直到结束阶段不能攻击的效果。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果相关，并尝试获得其控制权直到结束阶段；若控制权变更失败则不继续处理不能攻击效果。
	if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp,PHASE_END,1)~=0
		and e:GetLabel()~=1 then
		-- 这个效果的发动时自己场上没有「光之黄金柜」存在的场合，这个效果得到控制权的怪兽不能攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- ③攻击力上升效果的适用条件：当前回合玩家为这张卡的控制者，即仅在自己的回合内适用。
function s.atkcon(e)
	-- 判断当前回合玩家是否等于效果控制者，用于确保只有自己的回合才让其他怪兽攻击力上升。
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
-- ③效果的适用对象：这张卡以外的自己场上的怪兽，即“自己场上的其他怪兽”。
function s.atktg(e,c)
	return c~=e:GetHandler()
end
