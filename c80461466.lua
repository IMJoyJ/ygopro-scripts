--冥界の魔象
-- 效果：
-- 这张卡特殊召唤的场合，若自己场上有「活死人的呼声」或者「冥界的猛犸」以外的不死族怪兽存在：可以以场上1张卡为对象；那张卡破坏。「冥界的猛犸」的这个效果1回合只能使用1次。
-- 持有这张卡作为超量素材中的不死族超量怪兽得到以下效果。
-- ●这张卡的攻击力上升1000。
local s,id,o=GetID()
-- 初始化卡片效果：注册记述卡片「活死人的呼声」、①特殊召唤成功时破坏场上的卡效果、②作为不死族超量怪兽的超量素材赋予攻击力上升1000效果
function s.initial_effect(c)
	-- 注册卡片记述列表：记述卡片「活死人的呼声」（卡号97077563）
	aux.AddCodeList(c,97077563)
	-- 这张卡特殊召唤的场合，若自己场上有「活死人的呼声」或者「冥界的猛犸」以外的不死族怪兽存在：可以以场上1张卡为对象；那张卡破坏。
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
-- 条件过滤：表侧表示的「活死人的呼声」或自身以外的不死族怪兽
function s.cfilter(c)
	return c:IsFaceup() and ((c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_MONSTER) and not c:IsCode(id)) or c:IsCode(97077563))
end
-- ①效果发动条件：自己场上存在符合条件的怪兽或「活死人的呼声」
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在「活死人的呼声」或自身以外的不死族怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ①效果发动准备：选择场上1张卡为对象并设置破坏操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动条件检查：场上是否存在可作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息：破坏对象卡片1张
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果处理：破坏对象卡片
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 破坏目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 素材效果生效条件：持有此卡作为超量素材的怪兽必须是种族为不死族
function s.gfcon(e)
	return e:GetHandler():IsRace(RACE_ZOMBIE)
end
