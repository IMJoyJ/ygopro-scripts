--光の精霊 ディアーナ
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把1只光属性怪兽除外的场合可以特殊召唤。
-- ①：对方结束阶段发动。自己回复1000基本分。
function c17257342.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己墓地把1只光属性怪兽除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c17257342.spcon)
	e1:SetTarget(c17257342.sptg)
	e1:SetOperation(c17257342.spop)
	c:RegisterEffect(e1)
	-- ①：对方结束阶段发动。自己回复1000基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c17257342.reccon)
	e2:SetTarget(c17257342.rectg)
	e2:SetOperation(c17257342.recop)
	c:RegisterEffect(e2)
end
-- 筛选墓地中可作为特殊召唤代价的怪兽：必须是光属性，且允许从墓地除外作为cost。
function c17257342.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件判定：当c为nil时表示可直接显示该召唤手续；否则要求控制者tp场上主要怪兽区域有空位，且自己墓地存在至少1只满足spfilter的光属性怪兽。
function c17257342.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查控制者tp的主要怪兽区域是否有空位，确保特殊召唤后有可用的区域。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查tp的墓地中是否存在至少1张满足spfilter的光属性怪兽，用作特殊召唤时除外的代价。
		and Duel.IsExistingMatchingCard(c17257342.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 在特殊召唤手续中，从自己墓地的光属性怪兽里选择1张要除外的卡，并把它保存到效果标签中；选择成功则返回true，否则返回false。
function c17257342.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足spfilter条件的光属性怪兽，组成一个集合供玩家选择。
	local g=Duel.GetMatchingGroup(c17257342.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 向玩家显示选择提示，提示内容为“请选择要除外的卡”（HINTMSG_REMOVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的处理：取出之前选择好并保存在效果标签中的光属性怪兽，将其除外以完成特殊召唤的代价。
function c17257342.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的怪兽卡以表侧表示除外，除外原因标记为特殊召唤（REASON_SPSUMMON）。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- ①效果的发动条件：仅在当前回合玩家不是本卡控制者（即对方回合）时才能满足。
function c17257342.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不等于tp，即正处于对方回合，确保效果只在对方结束阶段发动。
	return Duel.GetTurnPlayer()~=tp
end
-- 设置回复效果的目标信息：将回复对象设为本卡控制者tp，回复数值设为1000，并登记操作信息让系统及后续连锁能够识别这是一个回复LP的效果。
function c17257342.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 把当前连锁的对象玩家设置为tp，即回复基本分的对象是本卡控制者。
	Duel.SetTargetPlayer(tp)
	-- 把当前连锁的对象参数设置为1000，作为后续处理时使用的回复数值。
	Duel.SetTargetParam(1000)
	-- 向系统登记本次操作信息：类别为回复（CATEGORY_RECOVER），不取对象，预计让tp回复1000点基本分，供其他卡片效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 效果处理：从当前连锁信息中取得之前设置的目标玩家和回复数值，并执行基本分回复。
function c17257342.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取出目标玩家p和参数d，分别对应回复对象和回复数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p回复d点基本分，回复原因记为效果（REASON_EFFECT）。
	Duel.Recover(p,d,REASON_EFFECT)
end
