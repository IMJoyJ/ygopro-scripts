--冥界の魔象
-- 效果：
-- 这张卡特殊召唤的场合，若自己场上有「活死人的呼声」或者「冥界的猛犸」以外的不死族怪兽存在：可以以场上1张卡为对象；那张卡破坏。「冥界的猛犸」的这个效果1回合只能使用1次。
-- 持有这张卡作为超量素材中的不死族超量怪兽得到以下效果。
-- ●这张卡的攻击力上升1000。
local s,id,o=GetID()
-- 初始化卡片效果：注册①特召成功破坏场上卡片效果、②作为超量素材给予不死族超量怪兽攻击力上升效果
function s.initial_effect(c)
	-- 注册卡片记述列表：记述「活死人的呼声」（卡号97077563）
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
-- 条件过滤：检查场上是否存在表侧表示的「活死人的呼声」或自身以外的不死族怪兽
function s.cfilter(c)
	return c:IsFaceup() and ((c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_MONSTER) and not c:IsCode(id)) or c:IsCode(97077563))
end
-- 发动条件检查：判断自己场上是否存在符合条件的卡
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「活死人的呼声」或自身以外的不死族怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 破坏效果准备：选择场上1张卡为对象并设置破坏操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动条件检查：场上是否存在可作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息：破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果处理：破坏选中的对象卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 破坏对象卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 获得效果条件检查：装备/素材持有的怪兽必须是种族为不死族的怪兽
function s.gfcon(e)
	return e:GetHandler():IsRace(RACE_ZOMBIE)
end
