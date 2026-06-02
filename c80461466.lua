--Great Mammoth of the Netherworld
-- 效果：
-- 这张卡特殊召唤的场合，若自己场上有「活死人的呼声」或者「冥界的猛犸」以外的不死族怪兽存在：可以以场上1张卡为对象；那张卡破坏。「冥界的猛犸」的这个效果1回合只能使用1次。
-- 持有这张卡作为超量素材中的不死族超量怪兽得到以下效果。
-- ●这张卡的攻击力上升1000。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数并记录关联卡片代码列表
function s.initial_effect(c)
	-- 记录该卡记载了「活死人的呼声」的卡片密码
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
-- 过滤自己场上表侧表示的「活死人的呼声」或者此卡名以外的不死族怪兽
function s.cfilter(c)
	return c:IsFaceup() and ((c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_MONSTER) and not c:IsCode(id)) or c:IsCode(97077563))
end
-- 破坏效果的发动条件函数
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在满足特定条件的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 破坏效果的发动靶子判定与效果对象选择
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 判定场上是否有任何可以成为效果对象的卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给玩家发送选择破坏卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 在场上选择1张卡片作为破坏效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息为破坏选择的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏场上被选为对象卡片的实际处理
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 将目标卡片因效果被破坏送去墓地
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判定持有这张卡作为超量素材的怪兽是否为不死族
function s.gfcon(e)
	return e:GetHandler():IsRace(RACE_ZOMBIE)
end
