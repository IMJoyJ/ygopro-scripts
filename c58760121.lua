--ワーム・ファルコ
-- 效果：
-- 反转：自己场上表侧表示存在的这张卡以外的名字带有「异虫」的爬虫类族怪兽全部变成里侧守备表示。
function c58760121.initial_effect(c)
	-- 反转：自己场上表侧表示存在的这张卡以外的名字带有「异虫」的爬虫类族怪兽全部变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FLIP+EFFECT_TYPE_SINGLE)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetTarget(c58760121.postg)
	e1:SetOperation(c58760121.posop)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示、卡名含有「异虫」且是爬虫类族的怪兽
function c58760121.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE)
end
-- 反转效果的发动准备与目标检测
function c58760121.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己场上除这张卡以外所有满足过滤条件的怪兽组
	local g=Duel.GetMatchingGroup(c58760121.filter,tp,LOCATION_MZONE,0,e:GetHandler())
	-- 设置操作信息为改变表示形式，数量为符合条件的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 反转效果的处理函数
function c58760121.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时自己场上除这张卡（若仍在场）以外所有满足过滤条件的怪兽组
	local g=Duel.GetMatchingGroup(c58760121.filter,tp,LOCATION_MZONE,0,aux.ExceptThisCard(e))
	-- 将目标怪兽全部改变为里侧守备表示
	Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE,0,POS_FACEDOWN_DEFENSE,0)
end
