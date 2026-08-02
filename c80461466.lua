--冥界の魔象
-- 效果：
-- 这张卡特殊召唤的场合，若自己场上有「活死人的呼声」或者「冥界的猛犸」以外的不死族怪兽存在：可以以场上1张卡为对象；那张卡破坏。「冥界的猛犸」的这个效果1回合只能使用1次。
-- 持有这张卡作为超量素材中的不死族超量怪兽得到以下效果。
-- ●这张卡的攻击力上升1000。
local s,id,o=GetID()
-- 声明初始化函数
function s.initial_effect(c)
	-- 记述「活死人的呼声」的卡名
	aux.AddCodeList(c,97077563)
	-- 这张卡特殊召唤的场合，若自己场上有「活死人的呼声」或者「冥界的猛犸」以外的不死族怪兽存在：可以以场上1张卡为对象；那张卡破坏。「冥界的猛犸」的这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_ACTIVATE_CONDITION)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- 持有这张卡作为超量素材中的不死族超量怪兽得到以下效果。●这张卡的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"上升攻击力"
	e2:SetType(EFFECT_TYPE_XMATERIAL)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1000)
	e2:SetCondition(s.gfcon)
	c:RegisterEffect(e2)
end
-- 检查是否是「活死人的呼声」或者「冥界的猛犸」以外的表侧表示不死族怪兽的过滤函数
function s.cfilter(c)
	return c:IsFaceup() and ((c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_MONSTER) and not c:IsCode(id)) or c:IsCode(97077563))
end
-- 破坏效果的发动条件：自己场上有满足条件的卡存在
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在满足上述条件的卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 破坏效果的取对象和执行目标设定
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在1张可以被选为对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上的1张卡作为对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设定将该卡破坏的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行过程
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 将该对象卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 攻击力上升效果的适用条件：该超量怪兽是不死族
function s.gfcon(e)
	return e:GetHandler():IsRace(RACE_ZOMBIE)
end
