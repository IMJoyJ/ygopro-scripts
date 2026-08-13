--エクシーズ・アライン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：宣言1～12的任意等级，以包含自己场上的怪兽的场上2只表侧表示怪兽为对象才能发动。那些怪兽的等级直到回合结束时变成宣言的等级。这张卡的发动后，直到回合结束时自己不是和作为对象的怪兽的其中任意种相同种族的怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：创建一个魔陷发动类效果，自由时点（2速）发动，设置1回合只能发动1张的誓约次数限制，标记为取对象效果，指定目标函数和处理函数，并注册给这张卡。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 目标过滤函数：筛选场上表侧表示、持有等级且可以被选为效果对象的怪兽。
function s.tgfilter(c,e)
	return c:IsFaceup() and c:IsLevelAbove(0) and c:IsCanBeEffectTarget(e)
end
-- 子组校验函数：要求所选怪兽组中至少包含1只自己场上的怪兽（满足以包含自己场上的怪兽的2只为对象）。
function s.gcheck(sg,tp)
	return sg:IsExists(Card.IsControler,1,nil,tp)
end
-- 目标选择函数：确认可发动条件后，从双方场上筛选满足条件的怪兽，提示玩家选择包含自己怪兽在内的2只怪兽作为对象并设置为连锁对象；若2只对象怪兽等级相同则记录该等级作为禁止宣言的等级，然后让玩家宣言1～12的等级并保存到效果标签。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检索双方场上主要怪兽区中表侧表示、持有等级且可以作为效果对象的怪兽组。
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return g:CheckSubGroup(s.gcheck,2,2,tp) end
	-- 向玩家提示「请选择要改变等级的怪兽」。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))  --"请选择要改变等级的怪兽"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2,tp)
	-- 把玩家选择的2只怪兽设置为当前连锁的对象。
	Duel.SetTargetCard(sg)
	local exlv=0
	if sg:GetClassCount(Card.GetLevel)==1 then
		exlv=sg:GetFirst():GetLevel()
	end
	-- 向玩家提示需要宣言等级。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 让玩家宣言1～12的任意等级（若2只对象怪兽等级相同则不可宣言该等级），并返回宣言的等级。
	local lv=Duel.AnnounceLevel(tp,1,12,exlv)
	e:SetLabel(lv)
end
-- 效果处理：取宣言的等级，对与连锁相关且表侧表示的对象怪兽逐一注册直到回合结束时等级变为宣言等级的效果，并记录对象怪兽的种族并集；若本效果是通过卡的发动产生且种族不为0，则注册一个直到回合结束时自己不能从额外卡组特殊召唤非对象怪兽相同种族怪兽的限制效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	local race=0
	-- 取得与当前连锁相关的对象怪兽中仍为表侧表示的怪兽组。
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsFaceup,nil)
	local tc=g:GetFirst()
	while tc do
		-- 那些怪兽的等级直到回合结束时变成宣言的等级。
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
		-- 把不能特殊召唤的限制效果注册给自己，直到回合结束时生效。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 限制判断函数：从额外卡组特殊召唤的怪兽，若其种族不是对象怪兽的任意种族之一，则不能特殊召唤。
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(e:GetLabel())
end
