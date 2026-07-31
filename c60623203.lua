--エクシーズ・アライン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：宣言1～12的任意等级，以包含自己场上的怪兽的场上2只表侧表示怪兽为对象才能发动。那些怪兽的等级直到回合结束时变成宣言的等级。这张卡的发动后，直到回合结束时自己不是和作为对象的怪兽的其中任意种相同种族的怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册①宣言等级·改变2只怪兽等级并限制额外卡组特殊召唤种族的激活效果
function s.initial_effect(c)
	-- ①：宣言1～12的任意等级，以包含自己场上的怪兽的场上2只表侧表示怪兽为对象才能发动。那些怪兽的等级直到回合结束时变成宣言的等级。这张卡的发动后，直到回合结束时自己不是和作为对象的怪兽的其中任意种相同种族的怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 对象过滤：表侧表示且有等级的怪兽
function s.tgfilter(c,e)
	return c:IsFaceup() and c:IsLevelAbove(0) and c:IsCanBeEffectTarget(e)
end
-- 组合过滤：选中的怪兽组合中必须包含自己控制的怪兽
function s.gcheck(sg,tp)
	return sg:IsExists(Card.IsControler,1,nil,tp)
end
-- ①效果发动准备：选择包含自己控制的2只怪兽为对象，并宣言1～12的等级
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取场上所有符合条件的怪兽
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return g:CheckSubGroup(s.gcheck,2,2,tp) end
	-- 提示玩家选择要改变等级的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))  --"请选择要改变等级的怪兽"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2,tp)
	-- 设置选中的怪兽为效果对象
	Duel.SetTargetCard(sg)
	local exlv=0
	if sg:GetClassCount(Card.GetLevel)==1 then
		exlv=sg:GetFirst():GetLevel()
	end
	-- 提示玩家选择等级
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 玩家宣言1～12的等级（若选中的2只怪兽原本等级相同，则不能宣言该等级）
	local lv=Duel.AnnounceLevel(tp,1,12,exlv)
	e:SetLabel(lv)
end
-- ①效果处理：将对象怪兽的等级变为宣言的等级，并注册额外卡组特殊召唤限制
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	local race=0
	-- 获取连锁中仍然表侧表示的对象怪兽
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsFaceup,nil)
	local tc=g:GetFirst()
	while tc do
		-- 直到回合结束时，等级变成宣言的等级。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		race=race|tc:GetRace()
		tc=g:GetNext()
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and race>0 then
		-- 这张卡的发动后，直到回合结束时自己不是和作为对象的怪兽的其中任意种相同种族的怪兽不能从额外卡组特殊召唤。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		e2:SetLabel(race)
		e2:SetTarget(s.splimit)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 为玩家注册本回合从额外卡组特殊召唤的种族限制效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 特殊召唤限制过滤：不能从额外卡组特殊召唤种族不属于对象怪兽种族的怪兽
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(e:GetLabel())
end
